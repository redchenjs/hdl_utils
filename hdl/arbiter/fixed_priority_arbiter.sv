/*
 * fixed_priority_arbiter.sv
 *
 *  Created on: 2023-12-18 00:03
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module fixed_priority_arbiter #(
    parameter int NUM_REQ   = 64,
    parameter int NUM_GRANT = 64,
    parameter bit REG_OUT   = 1
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [NUM_REQ-1:0] req_i,
    input logic               req_en_i,

    output logic [NUM_GRANT-1:0] grant_o
);

pri_64b #(
    .REG_OUT(REG_OUT)
) pri_64b (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i({{(64-NUM_REQ){1'b0}}, req_i}),
    .in_valid_i(req_en_i),

    .out_data_o(grant_o),
    .out_valid_o()
);

endmodule
