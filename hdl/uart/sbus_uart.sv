/*
 * sbus_uart.sv
 *
 *  Created on: 2021-08-22 18:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module sbus_uart #(
    parameter XLEN = 32,
    parameter BASE = 32'h4000_0000
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [XLEN-1:0] rd_addr_i,
    inout wire  [XLEN-1:0] rd_data_io,

    input logic [XLEN-1:0] wr_addr_i,
    input logic [XLEN-1:0] wr_data_i,

    input  logic rx_i,
    output logic tx_o
);

logic            wr_en;
logic [XLEN-1:0] wr_addr;
logic [XLEN-1:0] wr_data;

logic            rd_en;
logic [XLEN-1:0] rd_addr;
logic [XLEN-1:0] rd_data;

sbus2mmio #(
    .XLEN(XLEN),
    .BASE(BASE)
) sbus2mmio (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    // shared bus port
    .rd_addr_i(rd_addr_i),
    .rd_data_io(rd_data_io),

    .wr_addr_i(wr_addr_i),
    .wr_data_i(wr_data_i),

    // mmio port
    .wr_en_o(wr_en),
    .wr_addr_o(wr_addr),
    .wr_data_o(wr_data),

    .rd_en_o(rd_en),
    .rd_addr_o(rd_addr),
    .rd_data_i(rd_data)
);

mmio_uart #(
    .A_WIDTH(8),
    .D_WIDTH(32),
    .I_DEPTH(16),
    .O_DEPTH(32)
) mmio_uart (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .wr_en_i(wr_en),
    .wr_addr_i(wr_addr),
    .wr_data_i(wr_data),

    .rd_en_i(rd_en),
    .rd_addr_i(rd_addr),
    .rd_data_o(rd_data),

    .rx_i(rx_i),
    .tx_o(tx_o)
);

endmodule
