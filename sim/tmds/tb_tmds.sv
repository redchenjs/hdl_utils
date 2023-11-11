/*
 * tb_tmds.sv
 *
 *  Created on: 2023-11-12 00:02
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module tb_tmds;

logic clk_i;
logic rst_n_i;

logic de_i;
logic c1_i;
logic c0_i;

logic [7:0] d_i;
logic [9:0] q_o;

logic [7:0] d_o;

logic de_o;
logic c1_o;
logic c0_o;

tmds_encoder tmds_encoder(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .de_i(de_i),
    .c1_i(c1_i),
    .c0_i(c0_i),

    .d_i(d_i),
    .q_o(q_o)
);

tmds_decoder tmds_decoder(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .d_i(q_o),
    .q_o(d_o),

    .de_o(de_o),
    .c1_o(c1_o),
    .c0_o(c0_o)
);

initial begin
    clk_i   = 'b0;
    rst_n_i = 'b0;

    de_i = 'b0;
    c1_i = 'b0;
    c0_i = 'b0;

    d_i = 'b0;

    #2 rst_n_i = 'b1;
end

always begin
    #2.5 clk_i = ~clk_i;
end

always begin
    #3 {de_i, c1_i, c0_i} = 3'b0_00;

    #5 {de_i, c1_i, c0_i} = 3'b0_11;
    #5 {de_i, c1_i, c0_i} = 3'b0_10;
    #5 {de_i, c1_i, c0_i} = 3'b0_01;
    #5 {de_i, c1_i, c0_i} = 3'b0_00;

    for (int i = 0; i < 15; i++) begin
        #5 d_i = $random();

        {de_i, c1_i, c0_i} = 3'b1_00;        
    end

    #75 rst_n_i = 'b0;
    #25 $finish;
end

endmodule
