/*
 * tb_math_op.sv
 *
 *  Created on: 2023-11-25 05:30
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import math_pkg::*;

module tb_math_op;

parameter int MATH_OP = MATH_OP_OR;
parameter int I_COUNT = 5;
parameter int I_WIDTH = 8;
parameter int O_COUNT = 1;
parameter int O_WIDTH = 8;
parameter bit REG_OUT = 1;

logic clk_i;
logic rst_n_i;

logic [I_COUNT-1:0] [I_WIDTH-1:0] in_data_i;
logic                             in_valid_i;

logic [O_COUNT-1:0] [O_WIDTH-1:0] out_data_o;
logic                             out_valid_o;

math_op #(
    .MATH_OP(MATH_OP),
    .I_COUNT(I_COUNT),
    .I_WIDTH(I_WIDTH),
    .O_COUNT(O_COUNT),
    .O_WIDTH(O_WIDTH),
    .REG_OUT(REG_OUT)
) math_op(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i(in_data_i),
    .in_valid_i(in_valid_i),

    .out_data_o(out_data_o),
    .out_valid_o(out_valid_o)
);

initial begin
    clk_i   = 'b0;
    rst_n_i = 'b0;

    in_data_i  = 'b0;
    in_valid_i = 'b0;

    #6 rst_n_i = 'b1;
end

always begin
    #2.5 clk_i = ~clk_i;
end

always begin
    for (int i = 0; i < 512; i++) begin
        #5 in_data_i  = $random();
           in_valid_i = 'b1;
    end

    #75 rst_n_i = 'b0;
    #25 $finish;
end

endmodule
