/*
 * round_robin_arbiter.sv
 *
 *  Created on: 2023-12-18 00:03
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module round_robin_arbiter #(
    parameter int NUM_REQ   = 64,
    parameter int NUM_GRANT = 64
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [NUM_REQ-1:0] req_i,
    input logic               req_en_i,

    output logic [NUM_GRANT-1:0] grant_o
);

logic [NUM_REQ-1:0] req_m;

logic [NUM_GRANT-1:0] grant_m;
logic [NUM_GRANT-1:0] grant_n;

pri_64b #(
    .REG_OUT(0)
) pri_64b_m (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i({{(64-NUM_REQ){1'b0}}, req_i} & ~req_m),
    .in_valid_i('b1),

    .out_data_o(grant_m),
    .out_valid_o()
);

pri_64b #(
    .REG_OUT(0)
) pri_64b_n (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i({{(64-NUM_REQ){1'b0}}, req_i}),
    .in_valid_i('b1),

    .out_data_o(grant_n),
    .out_valid_o()
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        req_m   <= 'b0;
        grant_o <= 'b0;
    end else begin
        if (req_en_i) begin
            req_m   <= |grant_m ? (req_m | grant_m) : grant_n;
            grant_o <= |grant_m ?          grant_m  : grant_n;
        end
    end
end

endmodule
