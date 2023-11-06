/*
 * tb_ahb_sha2.sv
 *
 *  Created on: 2023-08-10 22:37
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import ahb_pkg::*;

module tb_ahb_sha2;

parameter A_WIDTH = 32;
parameter D_WIDTH = 32;

ahb_if #(
    .ADDR_WIDTH(A_WIDTH),
    .DATA_WIDTH(D_WIDTH)
) s_ahb();

logic s_irq;

ahb_sha2 #(
    .A_WIDTH(A_WIDTH),
    .D_WIDTH(D_WIDTH)
) ahb_sha2 (
    .s_ahb(s_ahb),
    .s_irq(s_irq)
);

initial begin
    s_ahb.hclk    <= 'b0;
    s_ahb.hresetn <= 'b0;

    s_ahb.hsel   <= 'b0;
    s_ahb.haddr  <= 'b0;
    s_ahb.hprot  <= 'b0;
    s_ahb.hsize  <= 'b0;
    s_ahb.htrans <= 'b0;
    s_ahb.hburst <= 'b0;
    s_ahb.hwrite <= 'b0;
    s_ahb.hwdata <= 'b0;

    #2 s_ahb.hresetn <= 'b1;
end

always begin
    #2.5 s_ahb.hclk <= ~s_ahb.hclk;
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
    s_ahb.hsel   <= 'b1;
    s_ahb.haddr  <= 'h0000;
    s_ahb.hprot  <= 'b0;
    s_ahb.hsize  <= 'h0;
    s_ahb.htrans <= AHB_TRANS_NONSEQ;
    s_ahb.hburst <= 'b0;
    s_ahb.hwrite <= 'b1;
    s_ahb.hwdata <= 'h0;            // dummy data

    #5  // write byte@0x0004
    s_ahb.hsel   <= 'b1;
    s_ahb.haddr  <= 'h0004;
    s_ahb.hprot  <= 'b0;
    s_ahb.hsize  <= 'h0;
    s_ahb.htrans <= AHB_TRANS_NONSEQ;
    s_ahb.hburst <= 'b0;
    s_ahb.hwrite <= 'b1;
    s_ahb.hwdata <= 'h0000_0001;    // rst_n = 1

    #5  // write byte@0x0008
    s_ahb.hsel   <= 'b1;
    s_ahb.haddr  <= 'h0008;
    s_ahb.hprot  <= 'b0;
    s_ahb.hsize  <= 'h0;
    s_ahb.htrans <= AHB_TRANS_NONSEQ;
    s_ahb.hburst <= 'b0;
    s_ahb.hwrite <= 'b1;
    s_ahb.hwdata <= 'h0000_0002;    // mode = 2'b01, last = 0

    #5  // write byte@0x000c
    s_ahb.hsel   <= 'b1;
    s_ahb.haddr  <= 'h000c;
    s_ahb.hprot  <= 'b0;
    s_ahb.hsize  <= 'h0;
    s_ahb.htrans <= AHB_TRANS_NONSEQ;
    s_ahb.hburst <= 'b0;
    s_ahb.hwrite <= 'b1;
    s_ahb.hwdata <= data_blk_0[data_cnt++];

    for (int i = 0; i < 15; i++) begin
        #5  // write byte@0x0008
        s_ahb.hsel   <= 'b1;
        s_ahb.haddr  <= 'h0008;
        s_ahb.hprot  <= 'b0;
        s_ahb.hsize  <= 'h0;
        s_ahb.htrans <= AHB_TRANS_NONSEQ;
        s_ahb.hburst <= 'b0;
        s_ahb.hwrite <= 'b1;
        s_ahb.hwdata <= 'b0;

        #5  // write byte@0x000c
        s_ahb.hsel   <= 'b1;
        s_ahb.haddr  <= 'h000c;
        s_ahb.hprot  <= 'b0;
        s_ahb.hsize  <= 'h0;
        s_ahb.htrans <= AHB_TRANS_NONSEQ;
        s_ahb.hburst <= 'b0;
        s_ahb.hwrite <= 'b1;
        s_ahb.hwdata <= data_blk_0[data_cnt++];
    end

    #5  // idle
    s_ahb.hsel   <= 'b1;
    s_ahb.haddr  <= 'h0;
    s_ahb.hprot  <= 'b0;
    s_ahb.hsize  <= 'h0;
    s_ahb.htrans <= AHB_TRANS_IDLE;
    s_ahb.hburst <= 'b0;
    s_ahb.hwrite <= 'b0;
    s_ahb.hwdata <= 'b0;

    #5  // read word@0x0004
    s_ahb.hsel   <= 'b1;
    s_ahb.haddr  <= 'h0004;
    s_ahb.hprot  <= 'b0;
    s_ahb.hsize  <= 'h0;
    s_ahb.htrans <= AHB_TRANS_NONSEQ;
    s_ahb.hburst <= 'b0;
    s_ahb.hwrite <= 'b0;
    s_ahb.hwdata <= 'b0;

    while (!(s_ahb.hrdata & 'h4000_0000)) begin
        #5  // read word@0x0004
            s_ahb.hsel   <= 'b1;
            s_ahb.haddr  <= 'h0004;
            s_ahb.hprot  <= 'b0;
            s_ahb.hsize  <= 'h0;
            s_ahb.htrans <= AHB_TRANS_NONSEQ;
            s_ahb.hburst <= 'b0;
            s_ahb.hwrite <= 'b0;
            s_ahb.hwdata <= 'h0;            // dummy data;
    end

    data_cnt <= 0;

    #5  // write byte@0x0004
    s_ahb.hsel   <= 'b1;
    s_ahb.haddr  <= 'h0004;
    s_ahb.hprot  <= 'b0;
    s_ahb.hsize  <= 'h0;
    s_ahb.htrans <= AHB_TRANS_NONSEQ;
    s_ahb.hburst <= 'b0;
    s_ahb.hwrite <= 'b1;
    s_ahb.hwdata <= 'h0;            // dummy data

    #5  // write byte@0x0008
    s_ahb.hsel   <= 'b1;
    s_ahb.haddr  <= 'h0008;
    s_ahb.hprot  <= 'b0;
    s_ahb.hsize  <= 'h0;
    s_ahb.htrans <= AHB_TRANS_NONSEQ;
    s_ahb.hburst <= 'b0;
    s_ahb.hwrite <= 'b1;
    s_ahb.hwdata <= 'h0000_0003;    // mode = 2'b01, last = 1

    #5  // write byte@0x000c
    s_ahb.hsel   <= 'b1;
    s_ahb.haddr  <= 'h000c;
    s_ahb.hprot  <= 'b0;
    s_ahb.hsize  <= 'h0;
    s_ahb.htrans <= AHB_TRANS_NONSEQ;
    s_ahb.hburst <= 'b0;
    s_ahb.hwrite <= 'b1;
    s_ahb.hwdata <= data_blk_1[data_cnt++];

    for (int i = 0; i < 15; i++) begin
        #5  // write byte@0x0008
        s_ahb.hsel   <= 'b1;
        s_ahb.haddr  <= 'h0008;
        s_ahb.hprot  <= 'b0;
        s_ahb.hsize  <= 'h0;
        s_ahb.htrans <= AHB_TRANS_NONSEQ;
        s_ahb.hburst <= 'b0;
        s_ahb.hwrite <= 'b1;
        s_ahb.hwdata <= 'b0;

        #5  // write byte@0x000c
        s_ahb.hsel   <= 'b1;
        s_ahb.haddr  <= 'h000c;
        s_ahb.hprot  <= 'b0;
        s_ahb.hsize  <= 'h0;
        s_ahb.htrans <= AHB_TRANS_NONSEQ;
        s_ahb.hburst <= 'b0;
        s_ahb.hwrite <= 'b1;
        s_ahb.hwdata <= data_blk_1[data_cnt++];
    end

    #5  // read word@0x0004
    s_ahb.hsel   <= 'b1;
    s_ahb.haddr  <= 'h0004;
    s_ahb.hprot  <= 'b0;
    s_ahb.hsize  <= 'h0;
    s_ahb.htrans <= AHB_TRANS_NONSEQ;
    s_ahb.hburst <= 'b0;
    s_ahb.hwrite <= 'b0;
    s_ahb.hwdata <= 'b0;

    while (!(s_ahb.hrdata & 'h8000_0000)) begin
        #5  // read word@0x0004
            s_ahb.hsel   <= 'b1;
            s_ahb.haddr  <= 'h0004;
            s_ahb.hprot  <= 'b0;
            s_ahb.hsize  <= 'h0;
            s_ahb.htrans <= AHB_TRANS_NONSEQ;
            s_ahb.hburst <= 'b0;
            s_ahb.hwrite <= 'b0;
            s_ahb.hwdata <= 'h0;
    end

    for (int i = 0; i < 8; i++) begin
        #5  // write word@0x0004
        s_ahb.hsel   <= 'b1;
        s_ahb.haddr  <= 'h0004;
        s_ahb.hprot  <= 'b0;
        s_ahb.hsize  <= 'h0;
        s_ahb.htrans <= AHB_TRANS_NONSEQ;
        s_ahb.hburst <= 'b0;
        s_ahb.hwrite <= 'b1;
        s_ahb.hwdata <= 'h0;

        #5  // read word@0x0010
        s_ahb.hsel   <= 'b1;
        s_ahb.haddr  <= 'h0010;
        s_ahb.hprot  <= 'b0;
        s_ahb.hsize  <= 'h0;
        s_ahb.htrans <= AHB_TRANS_NONSEQ;
        s_ahb.hburst <= 'b0;
        s_ahb.hwrite <= 'b0;
        s_ahb.hwdata <= 'h0008;

        #5  // read word@0x0014
        s_ahb.hsel   <= 'b1;
        s_ahb.haddr  <= 'h0014;
        s_ahb.hprot  <= 'b0;
        s_ahb.hsize  <= 'h0;
        s_ahb.htrans <= AHB_TRANS_NONSEQ;
        s_ahb.hburst <= 'b0;
        s_ahb.hwrite <= 'b0;
        s_ahb.hwdata <= 'h0;
    end

    #5  // idle
    s_ahb.hsel   <= 'b1;
    s_ahb.haddr  <= 'h0;
    s_ahb.hprot  <= 'b0;
    s_ahb.hsize  <= 'h0;
    s_ahb.htrans <= AHB_TRANS_IDLE;
    s_ahb.hburst <= 'b0;
    s_ahb.hwrite <= 'b0;
    s_ahb.hwdata <= 'h0;

    #7500 s_ahb.hresetn <= 'b0;
    #25 $finish;
end

endmodule
