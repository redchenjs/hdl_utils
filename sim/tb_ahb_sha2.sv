/*
 * tb_ahb_sha2.sv
 *
 *  Created on: 2023-08-10 22:37
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import ahb_enum::*;

module tb_ahb_sha2;

parameter A_WIDTH = 32;
parameter D_WIDTH = 32;

logic hclk_i;
logic hresetn_i;

logic               hsel_i;
logic [A_WIDTH-1:0] haddr_i;
logic         [3:0] hprot_i;
logic         [2:0] hsize_i;
logic         [1:0] htrans_i;
logic         [2:0] hburst_i;
logic               hwrite_i;
logic [D_WIDTH-1:0] hwdata_i;

logic         [1:0] hresp_o;
logic               hready_o;
logic [D_WIDTH-1:0] hrdata_o;

logic [1:0] irq_o;

ahb_sha2 #(
    .A_WIDTH(A_WIDTH),
    .D_WIDTH(D_WIDTH)
) ahb_sha2 (
    .hclk_i(hclk_i),
    .hresetn_i(hresetn_i),

    .hsel_i(hsel_i),
    .haddr_i(haddr_i),
    .hprot_i(hprot_i),
    .hsize_i(hsize_i),
    .htrans_i(htrans_i),
    .hburst_i(hburst_i),
    .hwrite_i(hwrite_i),
    .hwdata_i(hwdata_i),

    .hresp_o(hresp_o),
    .hready_o(hready_o),
    .hrdata_o(hrdata_o),

    .irq_o(irq_o)
);

initial begin
    hclk_i    <= 'b0;
    hresetn_i <= 'b0;

    hsel_i   <= 'b0;
    haddr_i  <= 'b0;
    hprot_i  <= 'b0;
    hsize_i  <= 'b0;
    htrans_i <= 'b0;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'b0;

    #2 hresetn_i <= 'b1;
end

always begin
    #2.5 hclk_i <= ~hclk_i;
end

logic [15:0] data_cnt;

logic [15:0] [31:0] data_blk_0 = {
    32'h2000_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h0000_0080, 32'h0a11_2001
};

logic [15:0] [31:0] data_blk_1 = {
    32'h2002_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h0000_0080, 32'h0a11_2001
};

always begin
    #3
    data_cnt <= 0;

    #5  // write byte@0x0000
    hsel_i   <= 'b1;
    haddr_i  <= 'h0000;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'h0;            // dummy data

    #5  // write byte@0x0004
    hsel_i   <= 'b1;
    haddr_i  <= 'h0004;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'h0000_0001;    // rst_n = 1

    #5  // write byte@0x0008
    hsel_i   <= 'b1;
    haddr_i  <= 'h0008;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'h0000_0002;    // mode = 2'b01, last = 0

    #5  // write byte@0x000c
    hsel_i   <= 'b1;
    haddr_i  <= 'h000c;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= data_blk_0[data_cnt++];

    for (int i = 0; i < 15; i++) begin
        #5  // write byte@0x0008
        hsel_i   <= 'b1;
        haddr_i  <= 'h0008;
        hprot_i  <= 'b0;
        hsize_i  <= 'h0;
        htrans_i <= AHB_TRANS_NONSEQ;
        hburst_i <= 'b0;
        hwrite_i <= 'b1;
        hwdata_i <= 'b0;

        #5  // write byte@0x000c
        hsel_i   <= 'b1;
        haddr_i  <= 'h000c;
        hprot_i  <= 'b0;
        hsize_i  <= 'h0;
        htrans_i <= AHB_TRANS_NONSEQ;
        hburst_i <= 'b0;
        hwrite_i <= 'b1;
        hwdata_i <= data_blk_0[data_cnt++];
    end

    #5  // idle
    hsel_i   <= 'b1;
    haddr_i  <= 'h0;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_IDLE;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'b0;

    #5  // read word@0x0004
    hsel_i   <= 'b1;
    haddr_i  <= 'h0004;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'b0;

    while (!(hrdata_o & 'h4000_0000)) begin
        #5  // read word@0x0004
            hsel_i   <= 'b1;
            haddr_i  <= 'h0004;
            hprot_i  <= 'b0;
            hsize_i  <= 'h0;
            htrans_i <= AHB_TRANS_NONSEQ;
            hburst_i <= 'b0;
            hwrite_i <= 'b0;
            hwdata_i <= 'h0;            // dummy data;
    end

    data_cnt <= 0;

    #5  // write byte@0x0004
    hsel_i   <= 'b1;
    haddr_i  <= 'h0004;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'h0;            // dummy data

    #5  // write byte@0x0008
    hsel_i   <= 'b1;
    haddr_i  <= 'h0008;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'h0000_0003;    // mode = 2'b01, last = 1

    #5  // write byte@0x000c
    hsel_i   <= 'b1;
    haddr_i  <= 'h000c;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= data_blk_1[data_cnt++];

    for (int i = 0; i < 15; i++) begin
        #5  // write byte@0x0008
        hsel_i   <= 'b1;
        haddr_i  <= 'h0008;
        hprot_i  <= 'b0;
        hsize_i  <= 'h0;
        htrans_i <= AHB_TRANS_NONSEQ;
        hburst_i <= 'b0;
        hwrite_i <= 'b1;
        hwdata_i <= 'b0;

        #5  // write byte@0x000c
        hsel_i   <= 'b1;
        haddr_i  <= 'h000c;
        hprot_i  <= 'b0;
        hsize_i  <= 'h0;
        htrans_i <= AHB_TRANS_NONSEQ;
        hburst_i <= 'b0;
        hwrite_i <= 'b1;
        hwdata_i <= data_blk_1[data_cnt++];
    end

    #5  // read word@0x0004
    hsel_i   <= 'b1;
    haddr_i  <= 'h0004;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'b0;

    while (!(hrdata_o & 'h8000_0000)) begin
        #5  // read word@0x0004
            hsel_i   <= 'b1;
            haddr_i  <= 'h0004;
            hprot_i  <= 'b0;
            hsize_i  <= 'h0;
            htrans_i <= AHB_TRANS_NONSEQ;
            hburst_i <= 'b0;
            hwrite_i <= 'b0;
            hwdata_i <= 'h0;
    end

    #5  // read word@0x0014
    hsel_i   <= 'b1;
    haddr_i  <= 'h0014;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0;

    #5  // read word@0x0010
    hsel_i   <= 'b1;
    haddr_i  <= 'h0010;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0;

    for (int i = 0; i < 7; i++) begin
        #5  // read word@0x0014
        hsel_i   <= 'b1;
        haddr_i  <= 'h0014;
        hprot_i  <= 'b0;
        hsize_i  <= 'h0;
        htrans_i <= AHB_TRANS_NONSEQ;
        hburst_i <= 'b0;
        hwrite_i <= 'b0;
        hwdata_i <= 'h0;

        #5  // read word@0x0010
        hsel_i   <= 'b1;
        haddr_i  <= 'h0010;
        hprot_i  <= 'b0;
        hsize_i  <= 'h0;
        htrans_i <= AHB_TRANS_NONSEQ;
        hburst_i <= 'b0;
        hwrite_i <= 'b0;
        hwdata_i <= 'h0;
    end

    #5  // idle
    hsel_i   <= 'b1;
    haddr_i  <= 'h0;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_IDLE;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0;

    #7500 hresetn_i <= 'b0;
    #25 $finish;
end

endmodule
