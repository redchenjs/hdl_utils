/*
 * stream_uart.sv
 *
 *  Created on: 2023-08-07 11:02
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module stream_uart #(
    parameter I_DEPTH = 16,
    parameter O_DEPTH = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [31:0] baud_div_i,

    input  logic [7:0] in_data_i,
    input  logic       in_valid_i,
    output logic       in_ready_o,

    output logic [7:0] out_data_o,
    output logic       out_valid_o,
    input  logic       out_ready_i,

    input  logic rx_i,
    output logic tx_o
);

logic in_fifo_full;
logic in_fifo_empty;

logic out_fifo_full;
logic out_fifo_empty;

logic [7:0] in_data;
logic       in_valid;
logic       in_ready;

logic [7:0] out_data;
logic       out_valid;
logic       out_ready;

assign in_ready_o = ~in_fifo_full;
assign in_valid   = ~in_fifo_empty;

assign out_ready   = ~out_fifo_full;
assign out_valid_o = ~out_fifo_empty;

fifo #(
    .I_WIDTH(8),
    .I_DEPTH(I_DEPTH),
    .O_WIDTH(8),
    .O_DEPTH(I_DEPTH)
) in_fifo (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .wr_en_i(in_valid_i),
    .wr_data_i(in_data_i),
    .wr_full_o(in_fifo_full),
    .wr_free_o(),

    .rd_en_i(in_ready),
    .rd_data_o(in_data),
    .rd_empty_o(in_fifo_empty),
    .rd_avail_o()
);

fifo #(
    .I_WIDTH(8),
    .I_DEPTH(O_DEPTH),
    .O_WIDTH(8),
    .O_DEPTH(O_DEPTH)
) out_fifo (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .wr_en_i(out_valid),
    .wr_data_i(out_data),
    .wr_full_o(out_fifo_full),
    .wr_free_o(),

    .rd_en_i(out_ready_i),
    .rd_data_o(out_data_o),
    .rd_empty_o(out_fifo_empty),
    .rd_avail_o()
);

uart_core uart_core(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .baud_div_i(baud_div_i),

    .in_data_i(in_data),
    .in_valid_i(in_valid),
    .in_ready_o(in_ready),

    .out_data_o(out_data),
    .out_valid_o(out_valid),
    .out_ready_i(out_ready),

    .rx_i(rx_i),
    .tx_o(tx_o)
);

endmodule
