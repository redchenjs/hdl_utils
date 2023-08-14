/*
 * tb_ahb_ws28xx.sv
 *
 *  Created on: 2023-08-14 16:21
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import ahb_enum::*;

module tb_ahb_ws28xx;

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

logic ws28xx_o;

ahb_ws28xx #(
    .A_WIDTH(A_WIDTH),
    .D_WIDTH(D_WIDTH)
) ahb_ws28xx (
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

    .ws28xx_o(ws28xx_o)
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
    32'h0000_0000, 32'h0f00_0000, 32'h0e00_0000, 32'h0d00_0000,
    32'h0c00_0000, 32'h0b00_0000, 32'h0a00_0000, 32'h0900_0000,
    32'h0800_0000, 32'h0700_0000, 32'h0600_0000, 32'h0500_0000,
    32'h0400_0000, 32'h0300_0000, 32'h0200_0000, 32'h0100_0000
};

logic [15:0] [31:0] data_blk_1 = {
    32'h0066_1111, 32'h0055_2222, 32'h0044_3333, 32'h0033_4444,
    32'h0022_5555, 32'h0011_6666, 32'h00ff_7777, 32'h00ee_8888,
    32'h00dd_9999, 32'h00cc_aaaa, 32'h00bb_bbbb, 32'h00aa_cccc,
    32'h0076_5432, 32'h0012_3456, 32'h00dd_eeff, 32'h00aa_bbcc
};

always begin
    #3 data_cnt <= 0;

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
    hwdata_i <= 'h0000_0002;    // addr = 1'b1, sync = 0

    #5  // write byte@0x0400
    hsel_i   <= 'b1;
    haddr_i  <= 'h0400;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'h0e0e_0e04;

    for (int i = 0; i < 15; i++) begin
        #5  // write byte@0x04xx
        hsel_i   <= 'b1;
        haddr_i  <= haddr_i + 4;
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
    hwdata_i <= data_blk_0[data_cnt];

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

    #5  // write byte@0x0400
    hsel_i   <= 'b1;
    haddr_i  <= 'h0400;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'h0000_0000;    // addr = 1'b0, sync = 0

    for (int i = 0; i < 15; i++) begin
        #5  // write byte@0x04xx
        hsel_i   <= 'b1;
        haddr_i  <= haddr_i + 4;
        hprot_i  <= 'b0;
        hsize_i  <= 'h0;
        htrans_i <= AHB_TRANS_NONSEQ;
        hburst_i <= 'b0;
        hwrite_i <= 'b1;
        hwdata_i <= data_blk_1[data_cnt++];
    end

    #5  // write byte@0x0004
    hsel_i   <= 'b1;
    haddr_i  <= 'h0004;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= data_blk_1[data_cnt];

    #5  // read word@0x0004
    hsel_i   <= 'b1;
    haddr_i  <= 'h0004;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0000_0001;    // addr = 1'b0, sync = 1

    #5  // read word@0x0004
    hsel_i   <= 'b1;
    haddr_i  <= 'h0004;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0;

    while (hrdata_o & 'h0000_0001) begin
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

    #5  // read word@0x0000
    hsel_i   <= 'b1;
    haddr_i  <= 'h0000;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0;

    #5  // read word@0x0000
    hsel_i   <= 'b1;
    haddr_i  <= 'h0000;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0;

    while (!(hrdata_o & 'h8000_0000)) begin
        #5  // read word@0x0000
        hsel_i   <= 'b1;
        haddr_i  <= 'h0000;
        hprot_i  <= 'b0;
        hsize_i  <= 'h0;
        htrans_i <= AHB_TRANS_NONSEQ;
        hburst_i <= 'b0;
        hwrite_i <= 'b0;
        hwdata_i <= 'h0;
    end

    #5  // write byte@0x0004
    hsel_i   <= 'b1;
    haddr_i  <= 'h0004;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'h0;            // dummy data;

    #5  // read word@0x0004
    hsel_i   <= 'b1;
    haddr_i  <= 'h0004;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0000_0001;    // addr = 1'b0, sync = 1

    #5  // read word@0x0004
    hsel_i   <= 'b1;
    haddr_i  <= 'h0004;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0;

    while (hrdata_o & 'h0000_0001) begin
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

    #5  // read word@0x0000
    hsel_i   <= 'b1;
    haddr_i  <= 'h0000;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0;

    #5  // read word@0x0000
    hsel_i   <= 'b1;
    haddr_i  <= 'h0000;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0;

    while (!(hrdata_o & 'h8000_0000)) begin
        #5  // read word@0x0000
        hsel_i   <= 'b1;
        haddr_i  <= 'h0000;
        hprot_i  <= 'b0;
        hsize_i  <= 'h0;
        htrans_i <= AHB_TRANS_NONSEQ;
        hburst_i <= 'b0;
        hwrite_i <= 'b0;
        hwdata_i <= 'h0;
    end

    #5  // read word@0x0008
    hsel_i   <= 'b1;
    haddr_i  <= 'h0008;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'b0;

    #5  // idle
    hsel_i   <= 'b1;
    haddr_i  <= 'h0;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_IDLE;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0;

    #75 hresetn_i <= 'b0;
    #25 $finish;
end

endmodule
