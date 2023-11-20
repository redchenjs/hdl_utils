/*
 * gmii_udp_tx.sv
 *
 *  Created on: 2023-11-21 02:26
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module gmii_udp_tx #(
    parameter int I_WIDTH = 8,
    parameter int O_WIDTH = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [I_WIDTH-1:0] in_data_i,
    input logic               in_valid_i,

    output logic [O_WIDTH-1:0] out_data_o,
    output logic               out_valid_o
);

endmodule
