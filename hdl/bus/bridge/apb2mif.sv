/*
 * apb2mif.sv
 *
 *  Created on: 2023-08-09 22:26
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module apb2mif #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    apb_if.slave  s_apb,
    mif_if.master m_mif
);

assign m_mif.wr_en     = s_apb.psel & s_apb.penable & s_apb.pwrite;
assign m_mif.wr_addr   = s_apb.paddr;
assign m_mif.wr_data   = s_apb.pwdata;
assign m_mif.wr_byteen = {(DATA_WIDTH/8){1'b1}};

assign m_mif.rd_en   = s_apb.psel & !s_apb.penable & !s_apb.pwrite;
assign m_mif.rd_addr = s_apb.paddr;

assign s_apb.prdata = m_mif.rd_data;

endmodule
