/*
 * ahb_lite_if.sv
 *
 *  Created on: 2023-11-04 01:06
 *      Author: Jack Chen <redchenjs@live.com>
 */

import ahb_lite_pkg::*;

interface ahb_lite_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 64
);
    // master signals
    logic [ADDR_WIDTH-1:0] haddr;
    ahb_lite_burst_t       hburst;
    logic                  hmastlock;
    ahb_lite_prot_t        hprot;
    ahb_lite_size_t        hsize;
    ahb_lite_trans_t       htrans;
    logic [DATA_WIDTH-1:0] hwdata;
    logic                  hwrite;
    // slave signals
    logic [DATA_WIDTH-1:0] hrdata;
    logic                  hreadyout;
    logic                  hresp;
    // decoder signals
    logic                  hsel;
    logic            [3:0] hslave;

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
        output hsel, hslave
    );
endinterface
