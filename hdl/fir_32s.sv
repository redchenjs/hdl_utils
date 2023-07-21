/*
 * fir_32s.sv
 *
 *  Created on: 2022-10-13 12:53
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module fir_32s #(
    parameter D_BITS = 16,
    parameter M_BITS = 16
) (
    input logic clk_i,
    input logic rst_n_i,

    input  logic signed        [D_BITS-1:0] x_i,
    input  logic signed [15:0] [M_BITS-1:0] a_i,
    output logic signed [D_BITS+M_BITS-1:0] y_o
);

logic signed [31:0]        [D_BITS-1:0] x_r;
logic signed [15:0] [D_BITS+M_BITS-1:0] s_a;
logic signed  [3:0] [D_BITS+M_BITS-1:0] s_b;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        x_r <= 'b0;
        s_a <= 'b0;
        s_b <= 'b0;
        y_o <= 'b0;
    end else begin
        x_r <= {x_r[30:0], x_i};

        for (int i = 0; i < 16; i++) begin
            s_a[i] <= {(x_r[i] + x_r[31 - i])} * a_i[i];
        end

        for (int i = 0; i < 4; i++) begin
            s_b[i] <= s_a[i * 4 + 0] + s_a[i * 4 + 1]
                    + s_a[i * 4 + 2] + s_a[i * 4 + 3];
        end

        y_o <= s_b[0] + s_b[1] + s_b[2] + s_b[3];
    end
end

endmodule
