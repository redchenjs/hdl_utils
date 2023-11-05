/*
 * ahb_lite_if.sv
 *
 *  Created on: 2023-11-04 01:06
 *      Author: Jack Chen <redchenjs@live.com>
 */

import ahb_lite_pkg::*;

interface ahb_lite_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    // decoder parameters
    parameter DEC_NUMBER = 1
);
    // master signals
    logic [ADDR_WIDTH-1:0] haddr;
    ahb_burst_t            hburst;
    logic                  hmastlock;
    ahb_prot_t             hprot;
    ahb_size_t             hsize;
    ahb_trans_t            htrans;
    logic [DATA_WIDTH-1:0] hwdata;
    logic                  hwrite;
    // slave signals
    logic [DATA_WIDTH-1:0] hrdata;
    logic                  hreadyout;
    logic                  hresp;
    // decoder signals
    logic                  hsel;
    logic [DEC_NUMBER-1:0] hselx;
    // multiplexor signals
    logic                                   hready;
    logic [DEC_NUMBER-1:0] [DATA_WIDTH-1:0] hrdatax;
    logic                  [DEC_NUMBER-1:0] hreadyoutx;
    ahb_resp_t             [DEC_NUMBER-1:0] hrespx;

    modport master (
        input hrdata, hready, hresp,
        output haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, hmastlock
    );

    modport slave (
        input hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, hready, hmastlock,
        output hrdata, hreadyout, hresp
    );

    modport decoder (
        input haddr,
        output hselx
    );

    modport multiplexor (
        input hselx, hrdatax, hreadyoutx, hrespx,
        output hrdata, hready, hresp
    );
endinterface
