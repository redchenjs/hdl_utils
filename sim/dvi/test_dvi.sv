/*
 * tb_dvi.sv
 *
 *  Created on: 2023-11-13 14:09
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import vendor_pkg::*;

module tb_dvi;

parameter bit EXTCLK = 0;
parameter int REFCLK = 74250000;
parameter int VENDOR = VENDOR_XILINX;

logic clk_i;
logic rst_n_i;

logic             de_i;
logic             vsync_i;
logic             hsync_i;
logic [2:0] [7:0] pixel_i; // {r[23:16], g[15:8], b[7:0]}

// tmds_o[0] : {clk_p, ch2_p, ch1_p, ch0_p} : {CLK, RED, GREEN, BLUE}
// tmds_o[1] : {clk_n, ch2_n, ch1_n, ch0_n} : {CLK, RED, GREEN, BLUE}
logic [1:0] [3:0] tmds_o;

logic             de_o;
logic             vsync_o;
logic             hsync_o;
logic [2:0] [7:0] pixel_o; // {r[23:16], g[15:8], b[7:0]}

logic clk_o;

dvi_tx #(
    .EXTCLK(EXTCLK),
    .REFCLK(REFCLK),
    .VENDOR(VENDOR_XILINX)
) dvi_tx(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .de_i(de_i),
    .vsync_i(vsync_i),
    .hsync_i(hsync_i),
    .pixel_i(pixel_i),

    .tmds_o(tmds_o)
);

dvi_rx #(
    .EXTCLK(EXTCLK),
    .REFCLK(REFCLK),
    .VENDOR(VENDOR_XILINX)
) dvi_rx(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .tmds_i(tmds_o),

    .de_o(de_o),
    .vsync_o(vsync_o),
    .hsync_o(hsync_o),
    .pixel_o(pixel_o),

    .clk_o(clk_o)
);

initial begin
    clk_i   = 'b0;
    rst_n_i = 'b0;

    de_i    = 'b0;
    vsync_i = 'b0;
    hsync_i = 'b0;
    pixel_i = 'b0;

    #2 rst_n_i = 'b1;
end

always begin
    #2.5 clk_i = ~clk_i;
end

always begin
    #3 {de_i, vsync_i, hsync_i} = 3'b0_00;

    #5 {de_i, vsync_i, hsync_i} = 3'b0_11;
    #5 {de_i, vsync_i, hsync_i} = 3'b0_10;
    #5 {de_i, vsync_i, hsync_i} = 3'b0_01;
    #5 {de_i, vsync_i, hsync_i} = 3'b0_00;

    for (int i = 0; i < 512; i++) begin
        #5 pixel_i = 24'hbeda_f789_0123;

        {de_i, vsync_i, hsync_i} = 3'b1_00;        
    end

    #75 rst_n_i = 'b0;
    #25 $finish;
end

endmodule
