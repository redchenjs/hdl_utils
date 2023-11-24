/*
 * half_adder.sv
 *
 *  Created on: 2023-11-24 13:46
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module half_adder(
    input logic a_i,
    input logic b_i,

    output logic s_o,
    output logic c_o
);

assign s_o = a_i ^ b_i;
assign c_o = a_i & b_i;

endmodule
