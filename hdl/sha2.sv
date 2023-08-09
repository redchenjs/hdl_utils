/*
 * sha2.sv
 *
 *  Created on: 2023-07-21 11:30
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module sha2 #(
    parameter I_DEPTH = 32,
    parameter O_DEPTH = 2
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [1:0] in_mode_i,
    input logic       in_last_i,

    input  logic [63:0] in_data_i,
    input  logic        in_valid_i,
    output logic        in_ready_o,

    output logic [63:0] out_data_o,
    output logic        out_valid_o,
    input  logic        out_ready_i
);

logic in_fifo_full;
logic in_fifo_empty;

logic out_fifo_full;
logic out_fifo_empty;

logic  [1:0] in_mode;
logic        in_last;

logic [63:0] in_data;
logic        in_valid;
logic        in_ready;

logic [511:0] out_data;
logic         out_valid;
logic         out_ready;

assign in_ready_o = ~in_fifo_full;
assign in_valid   = ~in_fifo_empty;

assign out_ready   = ~out_fifo_full;
assign out_valid_o = ~out_fifo_empty;

fifo #(
    .I_WIDTH(8),
    .I_DEPTH(I_DEPTH),
    .O_WIDTH(8),
    .O_DEPTH(I_DEPTH)
) fifo_in_ctrl (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .wr_en_i(in_valid_i),
    .wr_data_i({in_mode_i, in_last_i}),
    .wr_full_o(),
    .wr_free_o(),

    .rd_en_i(in_ready),
    .rd_data_o({in_mode, in_last}),
    .rd_empty_o(),
    .rd_avail_o()
);

fifo #(
    .I_WIDTH(64),
    .I_DEPTH(I_DEPTH),
    .O_WIDTH(64),
    .O_DEPTH(I_DEPTH)
) fifo_in_data (
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
    .I_WIDTH(512),
    .I_DEPTH(O_DEPTH),
    .O_WIDTH(64),
    .O_DEPTH(O_DEPTH*8)
) fifo_out_data (
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

sha2_core sha2_core(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_mode_i(in_mode),
    .in_last_i(in_last),

    .in_data_i(in_data),
    .in_valid_i(in_valid),
    .in_ready_o(in_ready),

    .out_data_o(out_data),
    .out_valid_o(out_valid),
    .out_ready_i(out_ready)
);

endmodule
