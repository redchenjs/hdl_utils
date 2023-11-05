/*
 * ahb_if.sv
 *
 *  Created on: 2023-11-03 03:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

import ahb_pkg::*;

interface ahb_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    // arbiter parameters
    parameter ARB_NUMBER = 1,
    // decoder parameters
    parameter DEC_NUMBER = 1
);
    logic                  hclk;
    logic                  hresetn;
    logic [ADDR_WIDTH-1:0] haddr;
    ahb_trans_t            htrans;
    logic                  hwrite;
    ahb_size_t             hsize;
    ahb_burst_t            hburst;
    ahb_prot_t             hprot;
    logic [DATA_WIDTH-1:0] hwdata;
    logic                  hsel;
    logic [DATA_WIDTH-1:0] hrdata;
    logic                  hready;
    ahb_resp_t             hresp;
    // arbitration signals
    logic                  hbusreq;
    logic                  hlock;
    logic                  hgrant;
    ahb_master_t           hmaster;
    logic                  hmastlock;
    ahb_split_t            hsplitx;
    // arbiter signals
    logic [ARB_NUMBER-1:0] hbusreqx;
    logic [ARB_NUMBER-1:0] hlockx;
    logic [ARB_NUMBER-1:0] hgrantx;
    // decoder signals
    logic [DEC_NUMBER-1:0] hselx;
    // multiplexor signals (master)
    logic [ARB_NUMBER-1:0] [ADDR_WIDTH-1:0] haddrx;
    logic [ARB_NUMBER-1:0] [DATA_WIDTH-1:0] hwdatax;
    // multiplexor signals (slave)
    logic [DEC_NUMBER-1:0] [DATA_WIDTH-1:0] hrdatax;
    logic                  [DEC_NUMBER-1:0] hreadyx;
    ahb_resp_t             [DEC_NUMBER-1:0] hrespx;

    modport master (
        input hrdata, hready, hresp, hgrant,
        output hclk, hresetn, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, hbusreq, hlock
    );

    modport slave (
        input hclk, hresetn, hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata,
        output hrdata, hready, hresp
    );

    modport slave_split (
        input hmaster, hmastlock,
        output hsplitx
    );

    modport arbiter (
        input hclk, hresetn, hbusreqx, hlockx, hsplitx, haddr, htrans, hburst, hready, hresp,
        output hgrantx, hmaster, hmastlock
    );

    modport decoder (
        input hclk, hresetn, haddr,
        output hselx
    );

    modport multiplexor_m (
        input hclk, hresetn, hgrantx, haddrx, hwdatax,
        output haddr, hwdata
    );

    modport multiplexor_s (
        input hclk, hresetn, hselx, hrdatax, hreadyx, hrespx,
        output hrdata, hready, hresp
    );
endinterface
