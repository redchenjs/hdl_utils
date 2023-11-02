/*
 * tb_fifo_dc.sv
 *
 *  Created on: 2022-12-23 20:11
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module tb_fifo_dc;

parameter I_WIDTH = 32;
parameter I_DEPTH = 16;
parameter O_WIDTH = 16;
parameter O_DEPTH = 32;

logic wr_clk_i;
logic wr_rst_n_i;

logic                     wr_en_i;
logic       [I_WIDTH-1:0] wr_data_i;
logic                     wr_full_o;
logic [$clog2(I_DEPTH):0] wr_free_o;

logic rd_clk_i;
logic rd_rst_n_i;

logic                     rd_en_i;
logic       [O_WIDTH-1:0] rd_data_o;
logic                     rd_empty_o;
logic [$clog2(O_DEPTH):0] rd_avail_o;

fifo_dc #(
    .I_WIDTH(I_WIDTH),
    .I_DEPTH(I_DEPTH),
    .O_WIDTH(O_WIDTH),
    .O_DEPTH(O_DEPTH)
) fifo_dc (
    .wr_clk_i(wr_clk_i),
    .wr_rst_n_i(wr_rst_n_i),

    .wr_en_i(wr_en_i),
    .wr_data_i(wr_data_i),
    .wr_full_o(wr_full_o),
    .wr_free_o(wr_free_o),

    .rd_clk_i(rd_clk_i),
    .rd_rst_n_i(rd_rst_n_i),

    .rd_en_i(rd_en_i),
    .rd_data_o(rd_data_o),
    .rd_empty_o(rd_empty_o),
    .rd_avail_o(rd_avail_o)
);

initial begin
    wr_clk_i   <= 1'b0;
    wr_rst_n_i <= 1'b0;

    wr_en_i   <= 'b0;
    wr_data_i <= 'b0;

    rd_clk_i   <= 1'b0;
    rd_rst_n_i <= 1'b0;

    rd_en_i <= 'b0;

    #2 wr_rst_n_i <= 1'b1;
       rd_rst_n_i <= 1'b1;
end

always begin
    #2.5 wr_clk_i <= ~wr_clk_i;
end

always begin
    #6 rd_clk_i <= ~rd_clk_i;
end

always begin
    #5 wr_en_i <= wr_en_i;

    for (int i = 0; i < 32; i++) begin
        #5 wr_en_i   <= 1'b1;
           wr_data_i <= $random;
    end
    #5 wr_en_i <= 1'b0;

    for (int i = 0; i < 16; i++) begin
        #12 rd_en_i <= 1'b1;
    end
    #12 rd_en_i <= 1'b0;

    for (int i = 0; i < 64; i++) begin
        #5 wr_en_i   <= 1'b1;
           wr_data_i <= $random;
    end
    #5 wr_en_i <= 1'b0;

    for (int i = 0; i < 64; i++) begin
        #12 rd_en_i <= 1'b1;
    end
    #12 rd_en_i <= 1'b0;

    #75 wr_rst_n_i <= 1'b0;
        rd_rst_n_i <= 1'b0;
    #25 $finish;
end

endmodule
