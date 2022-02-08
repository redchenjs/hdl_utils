/*
 * top_8.sv
 *
 *  Created on: 2022-01-05 22:56
 *      Author: Jack Chen <redchenjs@live.com>
 */

module top_8 #(
    parameter K = 8,
    parameter N = 16,
    parameter D_BITS = 12,
    parameter M_BITS = 16
) (
    input logic clk_i,      // 250 MHz clock
    input logic rst_n_i,    // active low

    input logic data_vld_i,

    input logic   [N-1:0] [D_BITS-1:0] data_x_i,
    input logic [K/2-1:0] [M_BITS-1:0] data_a_i,

    output logic data_rdy_o,

    output logic [N-1:0] [D_BITS-1:0] data_y_o
);

typedef enum logic [2:0] {
    IDLE,
    FILL_A,
    FILL_B,
    READ_A,
    READ_B
} state_t;

state_t state;

logic [K*4-1:0] [D_BITS-1:0] buff_t;
logic [K*3-1:0] [D_BITS-1:0] buff_x;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        state <= IDLE;

        buff_t <= {D_BITS*K*4{1'b0}};
        buff_x <= {D_BITS*K*3{1'b0}};

        data_rdy_o <= 1'b0;
    end else begin
        case (state)
            IDLE:
                state <= data_vld_i ? FILL_A : IDLE;
            FILL_A: begin
                state <= FILL_B;

                buff_t[K*2-1:0] <= data_x_i;
            end
            FILL_B: begin
                state <= READ_A;

                buff_t[K*4-1:K*2] <= data_x_i;
            end
            READ_A: begin
                state <= READ_B;

                buff_t[K*2-1:0] <= data_x_i;

                buff_x <= buff_t[K*3-1:0];
            end
            READ_B: begin
                state <= READ_A;

                buff_t[K*4-1:K*2] <= data_x_i;

                buff_x <= {buff_t[K-1:0], buff_t[K*4-1:K*2]};
            end
        endcase

        data_rdy_o <= (state == READ_A) ? 1'b1 : data_rdy_o;
    end
end

generate
    genvar i;
    for (i = 0; i < N; i++) begin
        comp #(
            .K(K),
            .N(N),
            .D_BITS(D_BITS),
            .M_BITS(M_BITS)
        ) comp_core (
            .x_i(buff_x[i+K-1:i]),
            .a_i(data_a_i),

            .y_o(data_y_o[i])
        );
    end
endgenerate

endmodule
