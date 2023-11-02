/*
 * tb_div_64b.sv
 *
 *  Created on: 2022-10-21 14:07
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module tb_div_64b;

logic clk_i;
logic rst_n_i;

logic init_i;
logic done_o;

logic [63:0] num_i;
logic [63:0] den_i;

logic [63:0] quo_o;
logic [63:0] rem_o;

div_64b div_64b(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i({num_i, den_i}),
    .in_valid_i(init_i),

    .out_data_o({quo_o, rem_o}),
    .out_valid_o(done_o)
);

initial begin
    clk_i   = 1'b0;
    rst_n_i = 1'b0;

    init_i = 'b0;

    num_i = 'b0;
    den_i = 'b0;

    quo_o = 'b0;
    rem_o = 'b0;

    #2 rst_n_i = 1'b1;
end

always begin
    #2.5 clk_i = ~clk_i;
end

always begin
    #5 init_i = 1'b1;
       num_i  = 'd1000001;
       den_i  = 'd100;

    // DATA
    for (int i = 0; i < 64; i++) begin
        #5 init_i = 1'b0;
    end

    #15 init_i = 1'b1;
        num_i  = -'d1000001;
        den_i  =  'd100;

    // DATA
    for (int i = 0; i < 64; i++) begin
        #5 init_i = 1'b0;
    end

    #15 init_i = 1'b1;
        num_i  =  'd1000001;
        den_i  = -'d100;

    // DATA
    for (int i = 0; i < 64; i++) begin
        #5 init_i = 1'b0;
    end

    #15 init_i = 1'b1;
        num_i  = -'d1000001;
        den_i  = -'d100;

    // DATA
    for (int i = 0; i < 64; i++) begin
        #5 init_i = 1'b0;
    end

    #75 rst_n_i = 1'b0;
    #25 $finish;
end

endmodule
