/*
 * test_sha256.sv
 *
 *  Created on: 2023-07-23 00:48
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module test_sha256;

parameter I_WIDTH = 512;
parameter O_WIDTH = 256;

logic clk_i;
logic rst_n_i;

logic init_i;
logic last_i;
logic done_o;

logic [I_WIDTH-1:0] data_i;
logic [O_WIDTH-1:0] data_o;

sha256 sha256(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i(data_i),
    .in_last_i(last_i),
    .in_valid_i(init_i),

    .out_data_o(data_o),
    .out_valid_o(done_o)
);

initial begin
    clk_i   = 'b0;
    rst_n_i = 'b0;

    init_i = 'b0;
    last_i = 'b0;
    data_i = 'b0;

    #2 rst_n_i = 'b1;
end

always begin
    #2.5 clk_i = ~clk_i;
end

always begin
    #5 init_i = 'b1;
       last_i = 'b1;

       data_i[I_WIDTH-8*0-1:I_WIDTH-8*1] = 'h01;
       data_i[I_WIDTH-8*1-1:I_WIDTH-8*2] = 'h20;
       data_i[I_WIDTH-8*2-1:I_WIDTH-8*3] = 'h11;
       data_i[I_WIDTH-8*3-1:I_WIDTH-8*4] = 'h0a;
       data_i[I_WIDTH-8*4-1:I_WIDTH-8*5] = 'h80;

       data_i[31:24] = 'h00;
       data_i[23:16] = 'h00;
       data_i[15: 8] = 'h00;
       data_i[ 7: 0] = 'h20;

    #5000 init_i = 'b0;
          last_i = 'b0;

    #75 rst_n_i = 'b0;
    #25 $finish;
end

endmodule
