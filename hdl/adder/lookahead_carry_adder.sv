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
        for (j = 0; j <= i; j++) begin: gen_c_y
            assign c_x[i][j][0] = g_t[j];

            for (k = 1; k <= i; k++) begin: gen_c_x
                assign c_x[i][j][k] = p_t[i-k];
            end

            math_op #(
                .MATH_OP(MATH_OP_AND),
                .I_COUNT(i-j+1),
                .I_WIDTH(1),
                .O_COUNT(1),
                .O_WIDTH(1),
                .REG_OUT(0)
            ) math_and(
                .clk_i(clk_i),
                .rst_n_i(rst_n_i),

                .in_data_i(c_x[i][j]),
                .in_valid_i(1'b1),

                .out_data_o(c_y[i][j]),
                .out_valid_o()
            );
        end

        math_op #(
            .MATH_OP(MATH_OP_OR),
            .I_COUNT(i+1),
            .I_WIDTH(1),
            .O_COUNT(1),
            .O_WIDTH(1),
            .REG_OUT(0)
        ) math_or(
            .clk_i(clk_i),
            .rst_n_i(rst_n_i),

            .in_data_i(c_y[i]),
            .in_valid_i(1'b1),

            .out_data_o(c_t[i]),
            .out_valid_o()
        );
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
