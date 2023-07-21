/*
 * uart_mmio.sv
 *
 *  Created on: 2021-08-22 18:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module uart_mmio #(
    parameter XLEN = 32,
    parameter BASE = 32'h4000_0000
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [XLEN-1:0] rd_addr_i,
    inout wire  [XLEN-1:0] rd_data_io,

    input logic         [XLEN-1:0] wr_addr_i,
    input logic         [XLEN-1:0] wr_data_i,
    input logic [$clog2(XLEN)-1:0] wr_byte_en_i,

    input  logic rx_i,
    output logic tx_o
);

logic [XLEN-1:0] rd_data;
logic            rd_en_r;

wire rd_en = (rd_addr_i[31:8] == BASE[31:8]);
wire wr_en = (wr_addr_i[31:8] == BASE[31:8]);

assign rd_data_io = rd_en_r ? rd_data : {XLEN{1'bz}};

uart_core #(
    .A_WIDTH(XLEN)
    .D_WIDTH(XLEN)
) uart_core (
    .clk_i(clk_i),
    .rst_n_i(uart_ctrl_1.rst_n),

    .wr_en_i(wr_en),
    .wr_addr_i(wr_addr_i),
    .wr_data_i(wr_data_i),
    .wr_byte_en_i(wr_byte_en_i),

    .rd_en_i(rd_en),
    .rd_addr_i(rd_addr_i),
    .rd_data_o(rd_data),

    .rx_i(rx_i),
    .tx_o(tx_o)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rd_en_r <= 'b0;
    end else begin
        rd_en_r <= rd_en;
    end
end

endmodule
