/*
 * tb_ahb_ram.sv
 *
 *  Created on: 2023-08-10 22:37
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import ahb_enum::*;

module tb_ahb_ram;

parameter INIT = 0;
parameter FILE = "ram_init.txt";
parameter A_WIDTH = 32;
parameter D_WIDTH = 32;
parameter D_DEPTH = 1024;

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

ahb_ram #(
    .INIT(INIT),
    .FILE(FILE),
    .A_WIDTH(A_WIDTH),
    .D_WIDTH(D_WIDTH),
    .D_DEPTH(D_DEPTH)
) ahb_ram (
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
    .hrdata_o(hrdata_o)
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

always begin
    #5  // write byte@0x8000
    hsel_i   <= 'b1;
    haddr_i  <= 'h8000;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'h0;            // dummy data

    #5  // write byte@0x8001
    hsel_i   <= 'b1;
    haddr_i  <= 'h8001;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_SEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'hdead_beef;    // data@0x8000

    #5  // write byte@0x8002
    hsel_i   <= 'b1;
    haddr_i  <= 'h8002;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_SEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'hdead_beef;    // data@0x8001

    #5  // write byte@0x8003
    hsel_i   <= 'b1;
    haddr_i  <= 'h8003;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_SEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'hdead_beef;    // data@0x8002

    #5  // write half_word@0x8004
    hsel_i   <= 'b1;
    haddr_i  <= 'h8004;
    hprot_i  <= 'b0;
    hsize_i  <= 'h1;
    htrans_i <= AHB_TRANS_SEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'hdead_beef;    //data@0x8003

    #5  // write half_word@0x8006
    hsel_i   <= 'b1;
    haddr_i  <= 'h8006;
    hprot_i  <= 'b0;
    hsize_i  <= 'h1;
    htrans_i <= AHB_TRANS_SEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'h7654_3210;    //data@0x8004

    #5  // write word@0x8008
    hsel_i   <= 'b1;
    haddr_i  <= 'h8008;
    hprot_i  <= 'b0;
    hsize_i  <= 'h2;
    htrans_i <= AHB_TRANS_SEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b1;
    hwdata_i <= 'h7654_3210;    //data@0x8006

    #5  // read byte@0x8000
    hsel_i   <= 'b1;
    haddr_i  <= 'h8000;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_NONSEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'hcbda_abdc;    //data@0x8008

    #5  // read byte@0x8001
    hsel_i   <= 'b1;
    haddr_i  <= 'h8001;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_SEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0;

    #5  // read byte@0x8002
    hsel_i   <= 'b1;
    haddr_i  <= 'h8002;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_SEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0;

    #5  // read byte@0x8003
    hsel_i   <= 'b1;
    haddr_i  <= 'h8003;
    hprot_i  <= 'b0;
    hsize_i  <= 'h0;
    htrans_i <= AHB_TRANS_SEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0;

    #5  // read half-word@0x8004
    hsel_i   <= 'b1;
    haddr_i  <= 'h8004;
    hprot_i  <= 'b0;
    hsize_i  <= 'h1;
    htrans_i <= AHB_TRANS_SEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0;

    #5  // read half-word@0x8006
    hsel_i   <= 'b1;
    haddr_i  <= 'h8006;
    hprot_i  <= 'b0;
    hsize_i  <= 'h1;
    htrans_i <= AHB_TRANS_SEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0;

    #5  // read word@0x8008
    hsel_i   <= 'b1;
    haddr_i  <= 'h8008;
    hprot_i  <= 'b0;
    hsize_i  <= 'h1;
    htrans_i <= AHB_TRANS_SEQ;
    hburst_i <= 'b0;
    hwrite_i <= 'b0;
    hwdata_i <= 'h0;

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
