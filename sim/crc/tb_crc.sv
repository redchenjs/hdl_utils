/*
 * tb_crc.sv
 *
 *  Created on: 2023-11-19 02:44
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module tb_crc;

parameter     bit REFI = 1;
parameter     bit REFO = 1;
parameter longint POLY = 32'h04c1_1db7;
parameter longint INIT = 32'hffff_ffff;
parameter longint XORO = 32'hffff_ffff;
parameter     int I_WIDTH = 8;
parameter     int O_WIDTH = 32;

logic clk_i;
logic rst_n_i;

logic [I_WIDTH-1:0] in_data_i;
logic               in_valid_i;

logic [O_WIDTH-1:0] out_data_o;
logic               out_valid_o;

crc #(
    .REFI(REFI),
    .REFO(REFO),
    .POLY(POLY),
    .INIT(INIT),
    .XORO(XORO),
    .I_WIDTH(I_WIDTH),
    .O_WIDTH(O_WIDTH)
) crc(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i(in_data_i),
    .in_valid_i(in_valid_i),

    .out_data_o(out_data_o),
    .out_valid_o(out_valid_o)
);

initial begin
    clk_i   = 'b0;
    rst_n_i = 'b0;

    in_data_i  = 'b0;
    in_valid_i = 'b0;

    #6 rst_n_i = 'b1;
end

always begin
    #2.5 clk_i = ~clk_i;
end

always begin
    for (int i = 0; i < 512; i++) begin
        #5 in_data_i  = $random();
           in_valid_i = 'b1;
    end

    #75 rst_n_i = 'b0;
    #25 $finish;
end

endmodule
