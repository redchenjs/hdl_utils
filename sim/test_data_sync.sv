/*
 * test_data_sync.sv
 *
 *  Created on: 2021-06-09 16:40
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_data_sync;

parameter WIDTH = 8;

logic clk_i;
logic rst_n_i;

logic [WIDTH-1:0] data_i;
logic [WIDTH-1:0] data_o;

data_sync #(
    .WIDTH(WIDTH)
) data_sync (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .data_i(data_i),
    .data_o(data_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    data_i <= 'b0;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    for (int i = 0; i < 64; i++) begin
        #3 data_i <= $random;
    end

    #10000 rst_n_i <= 1'b1;
    #25 $finish;
end

endmodule