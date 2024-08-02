/*
 * rst_sync.sv
 *
 *  Created on: 2020-05-07 18:57
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module rst_sync #(
    parameter int S_STAGE = 2
) (
    input logic clk_i,

    input  logic rst_n_i,
    output logic rst_n_o
);

// Data Sync
data_sync #(
    .S_STAGE(S_STAGE),
    .I_VALUE(0),
    .D_WIDTH(1)
) u_data_sync (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .data_i(1'b1),
    .data_o(rst_n_o)
)

endmodule
