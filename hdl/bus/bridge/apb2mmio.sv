/*
 * apb2mmio.sv
 *
 *  Created on: 2023-08-09 22:26
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import apb_pkg::*;

module apb2mmio #(
    parameter A_WIDTH = 32,
    parameter D_WIDTH = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    apb_if.slave #(
        .A_WIDTH(A_WIDTH),
        .D_WIDTH(D_WIDTH)
    ) s_apb,

    mmio_if.master #(
        .A_WIDTH(A_WIDTH),
        .D_WIDTH(D_WIDTH)
    ) m_mmio
);

assign m_mmio.wr_en     = s_apb.psel & s_apb.penable & s_apb.pwrite;
assign m_mmio.wr_addr   = s_apb.paddr;
assign m_mmio.wr_data   = s_apb.pwdata;
assign m_mmio.wr_byteen = {(D_WIDTH/8){1'b1}};

assign m_mmio.rd_en   = s_apb.psel & !s_apb.penable & !s_apb.pwrite;
assign m_mmio.rd_addr = s_apb.paddr;

assign s_apb.prdata = m_mmio.rd_data;

endmodule
