/*
 * uart.sv
 *
 *  Created on: 2023-08-07 11:02
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module uart #(
    parameter D_WIDTH = 32,
    parameter I_DEPTH = 16,
    parameter O_DEPTH = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic        [31:0] baud_div_i,

    input  logic [D_WIDTH-1:0] in_data_i,
    input  logic               in_valid_i,
    output logic               in_ready_o,

    output logic [D_WIDTH-1:0] out_data_o,
    output logic               out_valid_o,
    input  logic               out_ready_i,

    input  logic rx_i,
    output logic tx_o
);

logic tx_fifo_full;
logic tx_fifo_empty;

logic rx_fifo_full;
logic rx_fifo_empty;

logic [7:0] tx_data;
logic       tx_valid;
logic       tx_ready;

logic [7:0] rx_data;
logic       rx_valid;
logic       rx_ready;

assign  in_ready_o = ~tx_fifo_full;
assign  tx_valid   = ~tx_fifo_empty;
assign  rx_ready   = ~rx_fifo_full;
assign out_valid_o = ~rx_fifo_empty;

fifo #(
    .I_WIDTH(D_WIDTH),
    .I_DEPTH(I_DEPTH),
    .O_WIDTH(8),
    .O_DEPTH(D_WIDTH*I_DEPTH/8)
) fifo_tx (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .wr_en_i(in_valid_i),
    .wr_data_i(in_data_i),
    .wr_full_o(tx_fifo_full),
    .wr_free_o(),

    .rd_en_i(tx_ready),
    .rd_data_o(tx_data),
    .rd_empty_o(tx_fifo_empty),
    .rd_avail_o()
);

fifo #(
    .I_WIDTH(8),
    .I_DEPTH(D_WIDTH*O_DEPTH/8),
    .O_WIDTH(D_WIDTH),
    .O_DEPTH(O_DEPTH)
) fifo_rx (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .wr_en_i(rx_valid),
    .wr_data_i(rx_data),
    .wr_full_o(rx_fifo_full),
    .wr_free_o(),

    .rd_en_i(out_ready_i),
    .rd_data_o(out_data_o),
    .rd_empty_o(rx_fifo_empty),
    .rd_avail_o()
);

uart_tx uart_tx(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .baud_div_i(baud_div_i),

    .in_data_i(tx_data),
    .in_valid_i(tx_valid),
    .in_ready_o(tx_ready),

    .tx_o(tx_o)
);

uart_rx uart_rx(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .baud_div_i(baud_div_i),

    .out_data_o(rx_data),
    .out_valid_o(rx_valid),
    .out_ready_i(rx_ready),

    .rx_i(rx_i)
);

endmodule
