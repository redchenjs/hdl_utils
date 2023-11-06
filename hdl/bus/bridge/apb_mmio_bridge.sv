/*
 * apb_mmio_bridge.sv
 *
 *  Created on: 2023-08-09 22:26
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module apb_mmio_bridge #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    apb_if.slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) s_apb,

    mmio_if.master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) m_mmio
);

assign m_mmio.clk   = s_apb.pclk;
assign m_mmio.rst_n = s_apb.presetn;

assign m_mmio.wr_en     = s_apb.psel & s_apb.penable & s_apb.pwrite;
assign m_mmio.wr_addr   = s_apb.paddr;
assign m_mmio.wr_data   = s_apb.pwdata;
assign m_mmio.wr_byteen = {(DATA_WIDTH/8){1'b1}};

assign m_mmio.rd_en   = s_apb.psel & !s_apb.penable & !s_apb.pwrite;
assign m_mmio.rd_addr = s_apb.paddr;

assign s_apb.prdata = m_mmio.rd_data;

endmodule
