/*
 * sll_64b.sv
 *
 *  Created on: 2022-10-09 16:03
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module sll_64b #(
    parameter logic OUT_REG = 1'b1
) (
    input logic clk_i,
    input logic rst_n_i,

    input  logic init_i,
    output logic done_o,

    input logic [5:0] shift_i,

    input  logic [63:0] data_i,
    output logic [63:0] data_o
);

wire [63:0] data_0 = shift_i[0] ? {data_i[62:0], { 1{1'b0}}} : data_i;
wire [63:0] data_1 = shift_i[1] ? {data_0[61:0], { 2{1'b0}}} : data_0;
wire [63:0] data_2 = shift_i[2] ? {data_1[59:0], { 4{1'b0}}} : data_1;
wire [63:0] data_3 = shift_i[3] ? {data_2[55:0], { 8{1'b0}}} : data_2;
wire [63:0] data_4 = shift_i[4] ? {data_3[47:0], {16{1'b0}}} : data_3;
wire [63:0] data_5 = shift_i[5] ? {data_4[31:0], {32{1'b0}}} : data_4;

if (!OUT_REG) begin
    assign done_o = init_i;
    assign data_o = init_i ? data_5 : data_i;
end else begin
    always_ff @(posedge clk_i or negedge rst_n_i)
    begin
        if (!rst_n_i) begin
            done_o <= 'b0;
            data_o <= 'b0;
        end else begin
            done_o <= init_i;
            data_o <= init_i ? data_5 : data_o;
        end
    end
end

endmodule
