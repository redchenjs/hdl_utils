/*
 * rgb2grey.sv
 *
 *  Created on: 2022-04-04 11:05
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module rgb2grey(
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

logic [15:0] data_y;

wire [7:0] data_r = data_i[23:16];
wire [7:0] data_g = data_i[15:8];
wire [7:0] data_b = data_i[7:0];

assign data_o = {3{data_y[15:8]}};

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        data_y <= 16'h0000;
        done_o <= 1'b0;
    end else begin
        data_y <= init_i ? data_r * 77 + data_g * 150 + data_b * 29 : data_y;
        done_o <= init_i;
    end
end

endmodule
