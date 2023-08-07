/*
 * rgb2grey.sv
 *
 *  Created on: 2022-04-04 11:05
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module rgb2grey #(
    parameter REG_OUT = 1
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [23:0] in_data_i,
    input logic        in_valid_i,

    output logic [23:0] out_data_o,
    output logic        out_valid_o
);

// RGB => YUV
// Y = 0.299 R + 0.587 G + 0.114 B
// U = -0.1687 R - 0.3313 G + 0.5 B + 128
// V = 0.5 R - 0.4187 G - 0.0813 B + 128

// YUV => RGB
// R = Y + 1.402 (V - 128)
// G = Y - 0.34414 (U - 128) - 0.71414 (V - 128)
// B = Y + 1.772 (U - 128)

wire [7:0] data_r = in_data_i[23:16];
wire [7:0] data_g = in_data_i[15: 8];
wire [7:0] data_b = in_data_i[ 7: 0];

wire [15:0] data_y = data_r * 77 + data_g * 150 + data_b * 29;
wire [23:0] data_t = {3{data_y[15:8]}};

generate
    if (!REG_OUT) begin
        assign out_data_o  = in_valid_i ? data_t : in_data_i;
        assign out_valid_o = in_valid_i;
    end else begin
        always_ff @(posedge clk_i or negedge rst_n_i)
        begin
            if (!rst_n_i) begin
                out_data_o  <= 'b0;
                out_valid_o <= 'b0;
            end else begin
                out_data_o  <= in_valid_i ? data_t : out_data_o;
                out_valid_o <= in_valid_i;
            end
        end
    end
endgenerate

endmodule
