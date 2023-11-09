/*
 * tmds_encoder.sv
 *
 *  Created on: 2023-11-10 01:15
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module tmds_encoder (
    input logic clk_i,
    input logic rst_n_i,

    input logic de_i,
    input logic c0_i,
    input logic c1_i,

    input  logic [7:0] d_i,
    output logic [9:0] q_o
);


endmodule
