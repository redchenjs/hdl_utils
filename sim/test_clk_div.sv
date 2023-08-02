/*
 * test_clk_div.sv
 *
 *  Created on: 2023-08-03 02:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_clk_div;

parameter D_WIDTH = 8;

logic clk_i;
logic rst_n_i;

logic [D_WIDTH-1:0] div_i;
logic               clk_o;

clk_div #(
    .D_WIDTH(D_WIDTH)
) clk_div (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .div_i(div_i),
    .clk_o(clk_o)
);

initial begin
    clk_i   <= 'b1;
    rst_n_i <= 'b0;

    div_i <= 'b0;

    #2 rst_n_i <= 'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    for (int i = 0; i < 256; i++) begin
        #5120 div_i <= div_i + 'b1;
    end

    #75 rst_n_i <= 'b0;
    #25 $finish;
end

endmodule
