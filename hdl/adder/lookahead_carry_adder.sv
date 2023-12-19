/*
 * lookahead_carry_adder.sv
 *
 *  Created on: 2023-11-24 14:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import math_pkg::*;

module lookahead_carry_adder #(
    parameter int D_WIDTH = 64
) (
    input logic [D_WIDTH-1:0] a_i,
    input logic [D_WIDTH-1:0] b_i,
    input logic               c_i,

    output logic [D_WIDTH-1:0] s_o,
    output logic               c_o
);

logic [D_WIDTH-1:0] p_t;
logic [D_WIDTH  :0] g_t;

logic [D_WIDTH:0] [D_WIDTH:0] [D_WIDTH:0] c_x;
logic [D_WIDTH:0] [D_WIDTH:0]             c_y;
logic [D_WIDTH:0]                         c_t;

generate
    genvar i, j, k;

    assign g_t[0] = c_i;
    assign c_o    = c_t[D_WIDTH];

    for (i = 0; i <= D_WIDTH; i++) begin: gen_c_t
        for (j = 0; j <= D_WIDTH; j++) begin: gen_c_y
            if (j > i) begin
                assign c_y[i][j] = 'b0;
            end else begin
                assign c_x[i][j][0] = g_t[j];

                for (k = 1; k <= D_WIDTH; k++) begin: gen_c_x
                    assign c_x[i][j][k] = k <= (i - j) ? p_t[i-k] : 'b1;
                end

                assign c_y[i][j] = &c_x[i][j];
            end
        end

        assign c_t[i] = |c_y[i];
    end

    for (i = 0; i < D_WIDTH; i++) begin
        half_adder half_adder(
            .a_i(a_i[i]),
            .b_i(b_i[i]),

            .s_o(p_t[i]),
            .c_o(g_t[i+1])
        );

        assign s_o[i] = p_t[i] ^ c_t[i];
    end
endgenerate

endmodule
