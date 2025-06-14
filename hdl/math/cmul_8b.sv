/*
 * cmul_8b.sv
 *
 *  Created on: 2024-03-25 11:02
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module cmul_8b #(
    parameter int C_SIG = 0,
    parameter int C_VAL = 63
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [7:0] in_data_i,
    input logic       in_valid_i,

    output logic [$clog2(C_VAL)+8-1:0] out_data_o,
    output logic                       out_valid_o
);

logic [$clog2(C_VAL)-1:0] [$clog2(C_VAL)+8-1:0] data_s;
logic                     [$clog2(C_VAL)+8-1:0] data_n;

generate
    genvar i;

    for (i = 0; i < $clog2(C_VAL); i++) begin
        assign data_s[i] = C_VAL[i] ? {in_data_i, {i{1'b0}}}: 'b0;
    end

    assign out_data_o = C_SIG ? ~data_n + 'b1 : data_n;
endgenerate

math_op #(
    .MATH_OP(MATH_OP_ADD),
    .I_COUNT($clog2(C_VAL)),
    .I_WIDTH($clog2(C_VAL)+8),
    .O_COUNT(1),
    .O_WIDTH($clog2(C_VAL)+8),
    .REG_OUT(0)
) math_op_add (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i(data_s),
    .in_valid_i(in_valid_i),

    .out_data_o(data_n),
    .out_valid_o(out_valid_o)
);

endmodule
