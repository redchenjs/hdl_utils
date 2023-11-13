/*
 * tb_pll.sv
 *
 *  Created on: 2023-11-13 16:11
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import vendor_pkg::*;

module tb_pll;

parameter int VENDOR = VENDOR_XILINX;

logic clk_i;
logic rst_n_i;

logic clk_o;
logic rst_n_o;

pll #(
    .VENDOR(VENDOR_XILINX),
    .CLK_REF(200000000),
    .CLK_MUL(5),
    .CLK_DIV(2),
    .CLK_PHA(0)
) pll(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .clk_o(clk_o),
    .rst_n_o(rst_n_o)
);

initial begin
    clk_i   = 'b0;
    rst_n_i = 'b0;

    #2 rst_n_i = 'b1;
end

always begin
    #2.5 clk_i = ~clk_i;
end

always begin
    #7500 rst_n_i = 'b0;
    #25 $finish;
end

endmodule
