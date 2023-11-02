/*
 * tb_ahb_iopmp.sv
 *
 *  Created on: 2023-08-18 19:09
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import ahb_enum::*;

module tb_ahb_iopmp;

parameter A_WIDTH = 32;
parameter D_WIDTH = 32;

logic hclk_i;
logic hresetn_i;

// Config port
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

// Slave port 0
logic [A_WIDTH-1:0] s0_haddr_i;
logic         [3:0] s0_hprot_i;
logic         [2:0] s0_hsize_i;
logic         [1:0] s0_htrans_i;
logic         [2:0] s0_hburst_i;
logic               s0_hwrite_i;
logic [D_WIDTH-1:0] s0_hwdata_i;

logic         [1:0] s0_hresp_o;
logic               s0_hgrant_o;
logic               s0_hready_o;
logic [D_WIDTH-1:0] s0_hrdata_o;

// Slave port 1
logic [A_WIDTH-1:0] s1_haddr_i;
logic         [3:0] s1_hprot_i;
logic         [2:0] s1_hsize_i;
logic         [1:0] s1_htrans_i;
logic         [2:0] s1_hburst_i;
logic               s1_hwrite_i;
logic [D_WIDTH-1:0] s1_hwdata_i;

logic         [1:0] s1_hresp_o;
logic               s1_hgrant_o;
logic               s1_hready_o;
logic [D_WIDTH-1:0] s1_hrdata_o;

// Master port 0
logic [A_WIDTH-1:0] m0_haddr_o;
logic         [3:0] m0_hprot_o;
logic         [2:0] m0_hsize_o;
logic         [1:0] m0_htrans_o;
logic         [2:0] m0_hburst_o;
logic               m0_hwrite_o;
logic [D_WIDTH-1:0] m0_hwdata_o;

logic         [1:0] m0_hresp_i;
logic               m0_hgrant_i;
logic               m0_hready_i;
logic [D_WIDTH-1:0] m0_hrdata_i;

// Master port 1
logic [A_WIDTH-1:0] m1_haddr_o;
logic         [3:0] m1_hprot_o;
logic         [2:0] m1_hsize_o;
logic         [1:0] m1_htrans_o;
logic         [2:0] m1_hburst_o;
logic               m1_hwrite_o;
logic [D_WIDTH-1:0] m1_hwdata_o;

logic         [1:0] m1_hresp_i;
logic               m1_hgrant_i;
logic               m1_hready_i;
logic [D_WIDTH-1:0] m1_hrdata_i;

ahb_iopmp #(
    .A_WIDTH(A_WIDTH),
    .D_WIDTH(D_WIDTH)
) ahb_iopmp (
    .hclk_i(hclk_i),
    .hresetn_i(hresetn_i),

    // Config port
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

    // Slave port 0
    .s0_haddr_i(s0_haddr_i),
    .s0_hprot_i(s0_hprot_i),
    .s0_hsize_i(s0_hsize_i),
    .s0_htrans_i(s0_htrans_i),
    .s0_hburst_i(s0_hburst_i),
    .s0_hwrite_i(s0_hwrite_i),
    .s0_hwdata_i(s0_hwdata_i),

    .s0_hresp_o(s0_hresp_o),
    .s0_hgrant_o(s0_hgrant_o),
    .s0_hready_o(s0_hready_o),
    .s0_hrdata_o(s0_hrdata_o),

    // Slave port 1
    .s1_haddr_i(s1_haddr_i),
    .s1_hprot_i(s1_hprot_i),
    .s1_hsize_i(s1_hsize_i),
    .s1_htrans_i(s1_htrans_i),
    .s1_hburst_i(s1_hburst_i),
    .s1_hwrite_i(s1_hwrite_i),
    .s1_hwdata_i(s1_hwdata_i),

    .s1_hresp_o(s1_hresp_o),
    .s1_hgrant_o(s1_hgrant_o),
    .s1_hready_o(s1_hready_o),
    .s1_hrdata_o(s1_hrdata_o),

    // Master port 0
    .m0_haddr_o(m0_haddr_o),
    .m0_hprot_o(m0_hprot_o),
    .m0_hsize_o(m0_hsize_o),
    .m0_htrans_o(m0_htrans_o),
    .m0_hburst_o(m0_hburst_o),
    .m0_hwrite_o(m0_hwrite_o),
    .m0_hwdata_o(m0_hwdata_o),

    .m0_hresp_i(m0_hresp_i),
    .m0_hgrant_i(m0_hgrant_i),
    .m0_hready_i(m0_hready_i),
    .m0_hrdata_i(m0_hrdata_i),

    // Master port 1
    .m1_haddr_o(m1_haddr_o),
    .m1_hprot_o(m1_hprot_o),
    .m1_hsize_o(m1_hsize_o),
    .m1_htrans_o(m1_htrans_o),
    .m1_hburst_o(m1_hburst_o),
    .m1_hwrite_o(m1_hwrite_o),
    .m1_hwdata_o(m1_hwdata_o),

    .m1_hresp_i(m1_hresp_i),
    .m1_hgrant_i(m1_hgrant_i),
    .m1_hready_i(m1_hready_i),
    .m1_hrdata_i(m1_hrdata_i)
);

initial begin
    hclk_i    <= 'b0;
    hresetn_i <= 'b0;

    // Config port
    hsel_i   <= 'b0;
    haddr_i  <= 'b0;
    hprot_i  <= 'b0;
    hsize_i  <= 'b0;
    htrans_i <= 'b0;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'b0;

    // Slave port 0
    s0_haddr_i  <= 'b0;
    s0_hprot_i  <= 'b0;
    s0_hsize_i  <= 'b0;
    s0_htrans_i <= 'b0;
    s0_hburst_i <= 'b0;
    s0_hwrite_i <= 'b0;
    s0_hwdata_i <= 'b0;

    // Slave port 1
    s1_haddr_i  <= 'b0;
    s1_hprot_i  <= 'b0;
    s1_hsize_i  <= 'b0;
    s1_htrans_i <= 'b0;
    s1_hburst_i <= 'b0;
    s1_hwrite_i <= 'b0;
    s1_hwdata_i <= 'b0;

    // Master port 0
    m0_hresp_i  <= 'b0;
    m0_hgrant_i <= 'b0;
    m0_hready_i <= 'b0;
    m0_hrdata_i <= 'b0;

    // Master port 1
    m1_hresp_i  <= 'b0;
    m1_hgrant_i <= 'b0;
    m1_hready_i <= 'b0;
    m1_hrdata_i <= 'b0;

    #2 hresetn_i <= 'b1;
end

always begin
    #2.5 hclk_i <= ~hclk_i;
end

always begin
    #5  // write word@0x8000
    hsel_i   <= 'b1;
    haddr_i  <= 'h8000;
    hprot_i  <= 'b0;
    hsize_i  <= 'h2;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'h0;            // dummy data

    #5  // write word@0x8004
    hsel_i   <= 'b1;
    haddr_i  <= 'h8004;
    hprot_i  <= 'b0;
    hsize_i  <= 'h2;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'h0101_0000;

    #5  // write word@0x8020
    hsel_i   <= 'b1;
    haddr_i  <= 'h8020;
    hprot_i  <= 'b0;
    hsize_i  <= 'h2;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'h0101_0000;

    #5  // write word@0x8024
    hsel_i   <= 'b1;
    haddr_i  <= 'h8024;
    hprot_i  <= 'b0;
    hsize_i  <= 'h2;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'h2000_0000;

    #5  // write word@0x8060
    hsel_i   <= 'b1;
    haddr_i  <= 'h8060;
    hprot_i  <= 'b0;
    hsize_i  <= 'h2;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'hffff_0000;

    #5  // write word@0x8064
    hsel_i   <= 'b1;
    haddr_i  <= 'h8064;
    hprot_i  <= 'b0;
    hsize_i  <= 'h2;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'h4040_0000;

    #5  // idle
    hsel_i   <= 'b1;
    haddr_i  <= 'b0;
    hprot_i  <= 'b0;
    hsize_i  <= 'h2;
    htrans_i <= AHB_TRANS_IDLE;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'hffff_0000;

    #5
    s0_haddr_i  <= 'h2000_abcd;
    s0_hwrite_i <= 'b1;
    s0_htrans_i <= AHB_TRANS_NONSEQ;

    #5
    s0_haddr_i  <= 'h2000_abcd;
    s0_hwrite_i <= 'b0;
    s0_htrans_i <= AHB_TRANS_NONSEQ;

    #5
    s0_haddr_i  <= 'h4000_abcd;
    s0_hwrite_i <= 'b1;
    s0_htrans_i <= AHB_TRANS_NONSEQ;

    #5
    s0_haddr_i  <= 'h4000_abcd;
    s0_hwrite_i <= 'b0;
    s0_htrans_i <= AHB_TRANS_NONSEQ;

    #5
    s1_haddr_i  <= 'h4040_aaaa;
    s1_hwrite_i <= 'b1;
    s1_htrans_i <= AHB_TRANS_NONSEQ;

    #5
    s1_haddr_i  <= 'h4040_aaaa;
    s1_hwrite_i <= 'b0;
    s1_htrans_i <= AHB_TRANS_NONSEQ;

    #5
    s1_haddr_i  <= 'h4050_aaaa;
    s1_hwrite_i <= 'b1;
    s1_htrans_i <= AHB_TRANS_NONSEQ;

    #5
    s1_haddr_i  <= 'h4050_aaaa;
    s1_hwrite_i <= 'b0;
    s1_htrans_i <= AHB_TRANS_NONSEQ;

    #75 hresetn_i <= 'b0;
    #25 $finish;
end

endmodule
