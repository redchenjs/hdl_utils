/*
 * uart_core.sv
 *
 *  Created on: 2023-08-07 11:02
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module uart_core(
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

uart_tx uart_tx(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .baud_div_i(baud_div_i),

    .in_data_i(in_data_i),
    .in_valid_i(in_valid_i),
    .in_ready_o(in_ready_o),

    .tx_o(tx_o)
);

uart_rx uart_rx(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .baud_div_i(baud_div_i),

    .out_data_o(out_data_o),
    .out_valid_o(out_valid_o),
    .out_ready_i(out_ready_i),

    .rx_i(rx_i)
);

endmodule
