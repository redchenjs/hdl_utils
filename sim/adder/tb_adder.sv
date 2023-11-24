/*
 * tb_adder.sv
 *
 *  Created on: 2023-11-24 23:55
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module tb_adder;

parameter int D_WIDTH = 32;

logic clk_i;
logic rst_n_i;

logic [D_WIDTH-1:0] a_i;
logic [D_WIDTH-1:0] b_i;
logic               c_i;

logic [D_WIDTH-1:0] s_o_rca;
logic               c_o_rca;

logic [D_WIDTH-1:0] s_o_lca;
logic               c_o_lca;

rca #(
    .D_WIDTH(D_WIDTH)
) rca(
    .a_i(a_i),
    .b_i(b_i),
    .c_i(c_i),

    .s_o(s_o_rca),
    .c_o(c_o_rca)
);

lca #(
    .D_WIDTH(D_WIDTH)
) lca(
    .a_i(a_i),
    .b_i(b_i),
    .c_i(c_i),

    .s_o(s_o_lca),
    .c_o(c_o_lca)
);

initial begin
    clk_i   = 'b0;
    rst_n_i = 'b0;

    a_i = 'b0;
    b_i = 'b0;
    c_i = 'b0;

    #6 rst_n_i = 'b1;
end

always begin
    #2.5 clk_i = ~clk_i;
end

always begin
    for (int i = 0; i < 512; i++) begin
        #5 a_i = $random();
           b_i = $random();
           c_i = $random();
    end

    #75 rst_n_i = 'b0;
    #25 $finish;
end

endmodule
