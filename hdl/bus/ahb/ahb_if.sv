/*
 * ahb_if.sv
 *
 *  Created on: 2023-11-03 03:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

import ahb_pkg::*;

interface ahb_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 64
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
    ahb_master_t           hslave;
    ahb_master_t           hmaster;
    logic                  hmastlock;
    ahb_split_t            hsplitx;

    modport master (
        input hrdata, hready, hresp, hgrant,
        output hclk, hresetn, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, hbusreq, hlock
    );

    modport slave (
        input hclk, hresetn, hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, hmaster, hmastlock,
        output hrdata, hready, hresp, hsplitx
    );

    modport arbiter (
        input hclk, hresetn, haddr, htrans, hburst, hready, hresp, hbusreq, hlock, hsplitx,
        output hgrant, hmaster, hmastlock
    );

    modport decoder (
        input hclk, hresetn, haddr,
        output hsel, hslave
    );

    modport br_master (
        input hclk, hresetn, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, hbusreq, hlock,
        output hrdata, hready, hresp, hgrant
    );

    modport br_slave (
        input hclk, hresetn, hrdata, hready, hresp, hsplitx,
        output hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, hmaster, hmastlock
    );
endinterface
