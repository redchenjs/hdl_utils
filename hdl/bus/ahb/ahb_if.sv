/*
 * ahb_if.sv
 *
 *  Created on: 2023-11-03 03:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

import ahb_pkg::*;

interface ahb_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
);
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

    modport master (
        input hrdata, hready, hresp,
        output haddr, htrans, hwrite, hsize, hburst, hprot, hwdata
    );

    modport slave (
        output hrdata, hready, hresp,
        input haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, hsel
    );
endinterface
