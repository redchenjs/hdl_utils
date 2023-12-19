/*
 * tb_arbiter.sv
 *
 *  Created on: 2023-12-18 00:38
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module tb_arbiter;

parameter int NUM_REQ   = 4;
parameter int NUM_GRANT = 4;
parameter bit REG_OUT   = 1;

logic clk_i;
logic rst_n_i;

logic [NUM_REQ-1:0] req_i;
logic               req_en_i;

logic [NUM_GRANT-1:0] grant_o_fp;
logic [NUM_GRANT-1:0] grant_o_rr;

fixed_priority_arbiter #(
    .NUM_REQ(NUM_REQ),
    .NUM_GRANT(NUM_GRANT),
    .REG_OUT(REG_OUT)
) fpa(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .req_i(req_i),
    .req_en_i(req_en_i),

    .grant_o(grant_o_fp)
);

round_robin_arbiter #(
    .NUM_REQ(NUM_REQ),
    .NUM_GRANT(NUM_GRANT)
) rra(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .req_i(req_i),
    .req_en_i(req_en_i),

    .grant_o(grant_o_rr)
);

initial begin
    clk_i   = 'b0;
    rst_n_i = 'b0;

    req_i    = 'b0;
    req_en_i = 'b0;

    #6 rst_n_i = 'b1;
end

always begin
    #2.5 clk_i = ~clk_i;
end

always begin
    #15

    #5 req_en_i = 'b1; req_i = 4'b1111; // mask = 4'b0000, grant_o = 4'b1000
    #5 req_en_i = 'b1; req_i = 4'b1111; // mask = 4'b1000, grant_o = 4'b0100
    #5 req_en_i = 'b1; req_i = 4'b1111; // mask = 4'b1100, grant_o = 4'b0010
    #5 req_en_i = 'b1; req_i = 4'b1111; // mask = 4'b1110, grant_o = 4'b0001
    #5 req_en_i = 'b1; req_i = 4'b1111; // mask = 4'b1111, grant_o = 4'b1000
    #5 req_en_i = 'b1; req_i = 4'b1001; // mask = 4'b0000, grant_o = 4'b1000
    #5 req_en_i = 'b1; req_i = 4'b1001; // mask = 4'b1000, grant_o = 4'b0001
    #5 req_en_i = 'b1; req_i = 4'b1011; // mask = 4'b1001, grant_o = 4'b0010
    #5 req_en_i = 'b1; req_i = 4'b0001; // mask = 4'b0000, grant_o = 4'b0001

    #75 rst_n_i = 'b0;
    #25 $finish;
end

endmodule
