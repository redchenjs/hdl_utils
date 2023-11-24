/*
 * full_adder.sv
 *
 *  Created on: 2023-11-24 13:42
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module full_adder(
    input logic a_i,
    input logic b_i,
    input logic c_i,

    output logic s_o,
    output logic c_o
);

assign s_o = (a_i ^ b_i) ^ c_i;
assign c_o = (a_i & b_i) | (a_i & c_i) | (b_i & c_i);

endmodule
