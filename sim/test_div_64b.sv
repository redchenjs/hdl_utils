/*
 * test_div_64b.sv
 *
 *  Created on: 2022-10-21 14:07
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module test_div_64b;

logic clk_i;
logic rst_n_i;

logic init_i;
logic done_o;

logic [63:0] dividend_i;
logic [63:0] divisor_i;

logic [63:0] quotient_o;
logic [63:0] remainder_o;

div_64b div_64b(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .init_i(init_i),
    .done_o(done_o),

    .dividend_i(dividend_i),
    .divisor_i(divisor_i),

    .quotient_o(quotient_o),
    .remainder_o(remainder_o)
);

initial begin
    clk_i   = 1'b0;
    rst_n_i = 1'b0;

    init_i = 'b0;

    dividend_i = 'b0;
    divisor_i  = 'b0;

    quotient_o  = 'b0;
    remainder_o = 'b0;

    #2 rst_n_i = 1'b1;
end

always begin
    #2.5 clk_i = ~clk_i;
end

always begin
    #5 init_i = 1'b1;
       dividend_i = 'd1000001;
       divisor_i  = 'd100;

    // DATA
    for (int i = 0; i < 64; i++) begin
        #5 init_i = 1'b0;
    end

    #15 init_i = 1'b1;
        dividend_i = -'d1000001;
        divisor_i  =  'd100;

    // DATA
    for (int i = 0; i < 64; i++) begin
        #5 init_i = 1'b0;
    end

    #15 init_i = 1'b1;
        dividend_i =  'd1000001;
        divisor_i  = -'d100;

    // DATA
    for (int i = 0; i < 64; i++) begin
        #5 init_i = 1'b0;
    end

    #15 init_i = 1'b1;
        dividend_i = -'d1000001;
        divisor_i  = -'d100;

    // DATA
    for (int i = 0; i < 64; i++) begin
        #5 init_i = 1'b0;
    end

    #75 rst_n_i = 1'b0;
    #25 $finish;
end

endmodule
