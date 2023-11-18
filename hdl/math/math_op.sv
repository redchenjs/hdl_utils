/*
 * math_op.sv
 *
 *  Created on: 2023-11-19 13:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import math_pkg::*;

module math_op #(
    parameter int MATH_OP = MATH_OP_XOR,
    parameter int I_COUNT = 32,
    parameter int I_WIDTH = 4,
    parameter int O_WIDTH = 4,
    parameter bit REG_OUT = 1
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [I_COUNT-1:0] [I_WIDTH-1:0] in_data_i,
    input logic                             in_valid_i,

    output logic [O_WIDTH-1:0] out_data_o,
    output logic               out_valid_o
);

logic [$clog2(I_COUNT):0] [I_COUNT-1:0] [I_WIDTH-1:0] data_t;
logic                                   [O_WIDTH-1:0] data_r;

generate
    genvar i, j;

    for (i = 0; i <= $clog2(I_COUNT); i++) begin
        for (j = 0; j < I_COUNT; j++) begin
            case (MATH_OP)
            MATH_OP_ADD: assign data_t[i+1][j] = data_t[i][j*2] + data_t[i][j*2+1];
            MATH_OP_XOR: assign data_t[i+1][j] = data_t[i][j*2] ^ data_t[i][j*2+1];
            endcase
        end
    end

    assign data_t[0] = in_data_i;
    assign data_r    = data_t[$clog2(I_COUNT)][0];

    if (REG_OUT) begin
        always_ff @(posedge clk_i or negedge rst_n_i)
        begin
            if (!rst_n_i) begin
                out_data_o  <= 'b0;
                out_valid_o <= 'b0;
            end else begin
                out_data_o  <= in_valid_i ? data_r : out_data_o;
                out_valid_o <= in_valid_i;
            end
        end
    end else begin
        assign out_data_o  = in_valid_i ? data_r : 'b0;
        assign out_valid_o = in_valid_i;
    end
endgenerate

endmodule
