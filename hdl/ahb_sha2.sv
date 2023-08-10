/*
 * ahb_sha2.sv
 *
 *  Created on: 2021-08-22 18:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import ahb_enum::*;

module ahb_sha2 #(
    parameter A_WIDTH = 32,
    parameter D_WIDTH = 32
) (
    input logic hclk_i,
    input logic hresetn_i,

    // ahb port
    input logic               hsel_i,
    input logic [A_WIDTH-1:0] haddr_i,
    input logic         [3:0] hprot_i,
    input logic         [2:0] hsize_i,
    input logic         [1:0] htrans_i,
    input logic         [2:0] hburst_i,
    input logic               hwrite_i,
    input logic [D_WIDTH-1:0] hwdata_i,

    output logic         [1:0] hresp_o,
    output logic               hready_o,
    output logic [D_WIDTH-1:0] hrdata_o,

    output logic [1:0] irq_o
);

logic               wr_en;
logic [A_WIDTH-1:0] wr_addr;
logic [D_WIDTH-1:0] wr_data;

logic               rd_en;
logic [A_WIDTH-1:0] rd_addr;
logic [D_WIDTH-1:0] rd_data;

ahb2mmio #(
    .A_WIDTH(A_WIDTH),
    .D_WIDTH(D_WIDTH)
) ahb2mmio (
    .hclk_i(hclk_i),
    .hresetn_i(hresetn_i),

    // ahb port
    .hsel_i(hsel_i),
    .haddr_i(haddr_i),
    .hprot_i(hprot_i),
    .hsize_i(hsize_i),
    .htrans_i(htrans_i),
    .hburst_i(hburst_i),
    .hwrite_i(hwrite_i),
    .hwdata_i(hwdata_i),

    .hresp_o(hresp_o),
    .hready_o(hready_o),
    .hrdata_o(hrdata_o),

    // mmio port
    .wr_en_o(wr_en),
    .wr_addr_o(wr_addr),
    .wr_data_o(wr_data),

    .rd_en_o(rd_en),
    .rd_addr_o(rd_addr),
    .rd_data_i(rd_data)
);

mmio_sha2 #(
    .A_WIDTH(A_WIDTH),
    .D_WIDTH(D_WIDTH),
    .I_DEPTH(32),
    .O_DEPTH(2)
) mmio_sha2 (
    .clk_i(hclk_i),
    .rst_n_i(hresetn_i),

    .wr_en_i(wr_en),
    .wr_addr_i(wr_addr),
    .wr_data_i(wr_data),

    .rd_en_i(rd_en),
    .rd_addr_i(rd_addr),
    .rd_data_o(rd_data),

    .intr_done_o(irq_o[1]),
    .intr_next_o(irq_o[0])
);

endmodule
