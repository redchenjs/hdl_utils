/*
 * test_bit_sync.sv
 *
 *  Created on: 2021-06-09 16:40
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_bit_sync;

logic clk_i;
logic rst_n_i;

logic bit_i;
logic bit_o;

bit_sync bit_sync(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .bit_i(bit_i),
    .bit_o(bit_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    bit_i <= 1'b0;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    #3 bit_i <= ~bit_i;

    #100 rst_n_i <= 1'b1;
    #25 $finish;
end

endmodule
