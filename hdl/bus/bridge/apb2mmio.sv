/*
 * apb2mmio.sv
 *
 *  Created on: 2023-08-09 22:26
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import apb_enum::*;

module apb2mmio #(
    parameter A_WIDTH = 32,
    parameter D_WIDTH = 32
) (
    input logic pclk_i,
    input logic presetn_i,

    // apb port
    input logic               psel_i,
    input logic [A_WIDTH-1:0] paddr_i,
    input logic               pwrite_i,
    input logic [D_WIDTH-1:0] pwdata_i,
    input logic               penable_i,

    output logic [D_WIDTH-1:0] prdata_o,

    // mmio port
    output logic               wr_en_o,
    output logic [A_WIDTH-1:0] wr_addr_o,
    output logic [D_WIDTH-1:0] wr_data_o,

    output logic               rd_en_o,
    output logic [A_WIDTH-1:0] rd_addr_o,
    input  logic [D_WIDTH-1:0] rd_data_i
);

assign wr_en_o   = psel_i & penable_i & pwrite_i;
assign wr_addr_o = paddr_i;
assign wr_data_o = pwdata_i;

assign rd_en_o   = psel_i & !penable_i & !pwrite_i;
assign rd_addr_o = paddr_i;

assign prdata_o = rd_data_i;

endmodule
