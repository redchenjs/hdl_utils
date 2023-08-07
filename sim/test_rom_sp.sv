/*
 * test_rom_sp.sv
 *
 *  Created on: 2023-05-11 05:31
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module test_rom_sp;

parameter PATH = "rom_init.txt";
parameter D_WIDTH = 32;
parameter DEPTH = 65536;
parameter REG_OUT = 1;

logic rd_clk_i;

logic                     rd_en_i;
logic [$clog2(DEPTH)-1:0] rd_addr_i;
logic         [D_WIDTH-1:0] rd_data_o;

rom_sp #(
    .PATH(PATH),
    .D_WIDTH(D_WIDTH),
    .DEPTH(DEPTH),
    .REG_OUT(REG_OUT)
) rom_sp (
    .rd_clk_i(rd_clk_i),

    .rd_en_i(rd_en_i),
    .rd_addr_i(rd_addr_i),
    .rd_data_o(rd_data_o)
);

initial begin
    rd_clk_i = 'b0;

    rd_en_i   = 'b0;
    rd_addr_i = 'b0;
end

always begin
    #2.5 rd_clk_i = ~rd_clk_i;
end

always begin
    #5 rd_en_i = 'b1;

    for (int i = 0; i < 65536; i++) begin
        #5 rd_addr_i = rd_addr_i + 'b1;
    end

    #5 rd_en_i = 1'b0;

    #25 $finish;
end

endmodule
