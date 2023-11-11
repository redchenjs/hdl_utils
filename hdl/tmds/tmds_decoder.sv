/*
 * tmds_decoder.sv
 *
 *  Created on: 2023-11-11 17:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module tmds_decoder (
    input logic clk_i,
    input logic rst_n_i,

    input  logic [9:0] q_i,
    output logic [7:0] d_o,

    output logic de_o,
    output logic c0_o,
    output logic c1_o
);

always_comb begin
    if (!de_i) begin
        c_n = 'b0;

        case ({c1_i, c0_i})
            2'b00: q_n = 10'b11_0101_0100;
            2'b01: q_n = 10'b00_1010_1011;
            2'b10: q_n = 10'b01_0101_0100;
            2'b11: q_n = 10'b10_1010_1011;
        endcase
    end else begin
        if ((c_t == 0) | (n_1 == n_0)) begin
            c_n = q_m[8] ? c_t + (n_1 - n_0) : c_t - (n_1 - n_0);

            q_n = {~q_m[8], q_m[8], (q_m[8] ? q_m[7:0] : ~q_m[7:0])};
        end else begin
            if (((c_t > 0) & (n_1 > n_0)) |
                ((c_t < 0) & (n_1 < n_0))) begin
                c_n = c_t + {q_m[8], 1'b0} - (n_1 - n_0);

                q_n = {1'b1, q_m[8], ~q_m[7:0]};
            end else begin
                c_n = c_t - {~q_m[8], 1'b0} + (n_1 - n_0);

                q_n = {1'b0, q_m[8], q_m[7:0]};
            end
        end
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        c_t <= 'b0;
        q_o <= 'b0;
    end else begin
        c_t <= c_n;
        q_o <= q_n;
    end
end

endmodule
