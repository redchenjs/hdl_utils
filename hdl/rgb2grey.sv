/*
 * rgb2grey.sv
 *
 *  Created on: 2022-04-04 11:05
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module rgb2grey #(
    parameter logic OUT_REG = 1'b1
) (
    input logic clk_i,
    input logic rst_n_i,

    input  logic init_i,
    output logic done_o,

    input  logic [23:0] data_i,
    output logic [23:0] data_o
);

// RGB => YUV
// Y = 0.299 R + 0.587 G + 0.114 B
// U = -0.1687 R - 0.3313 G + 0.5 B + 128
// V = 0.5 R - 0.4187 G - 0.0813 B + 128

// YUV => RGB
// R = Y + 1.402 (V - 128)
// G = Y - 0.34414 (U - 128) - 0.71414 (V - 128)
// B = Y + 1.772 (U - 128)

wire [7:0] data_r = data_i[23:16];
wire [7:0] data_g = data_i[15:8];
wire [7:0] data_b = data_i[7:0];

wire [15:0] data_y = data_r * 77 + data_g * 150 + data_b * 29;

if (!OUT_REG) begin
    assign done_o = init_i;
    assign data_o = init_i ? {3{data_y[15:8]}} : data_i;
end else begin
    always_ff @(posedge clk_i or negedge rst_n_i)
    begin
        if (!rst_n_i) begin
            done_o <= 'b0;
            data_o <= 'b0;
        end else begin
            done_o <= init_i;
            data_o <= init_i ? {3{data_y[15:8]}} : data_o;
        end
    end
end

endmodule
