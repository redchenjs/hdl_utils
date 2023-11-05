/*
 * axi4_lite_if.sv
 *
 *  Created on: 2023-11-06 00:55
 *      Author: Jack Chen <redchenjs@live.com>
 */

import axi4_lite_pkg::*;

interface axi4_lite_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
);
    // write address channel
    axi_id_t               awid;
    logic [ADDR_WIDTH-1:0] awaddr;
    axi_prot_t             awprot;
    logic                  awvalid;
    logic                  awready;
    // write data channel
    logic   [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH/8-1:0] wstrb;
    logic                    wvalid;
    logic                    wready;
    // write response channel
    axi_id_t   bid;
    axi_resp_t bresp;
    logic      bvalid;
    logic      bready;
    // read address channel
    axi_id_t               arid;
    logic [ADDR_WIDTH-1:0] araddr;
    axi_prot_t             arprot;
    logic                  arvalid;
    logic                  arready;
    // read data channel
    axi_id_t               rid;
    logic [DATA_WIDTH-1:0] rdata;
    axi_resp_t             rresp;
    logic                  rvalid;
    logic                  rready;

    modport master (
        // write address channel
        input awready,
        output awaddr, awprot, awvalid,
        // write data channel
        input wready,
        output wdata, wstrb, wvalid,
        // write response channel
        input bresp, bvalid,
        output bready,
        // read address channel
        input arready,
        output araddr, arprot, arvalid,
        // read data channel
        input rdata, rresp, rvalid,
        output rready
    );

    modport slave (
        // write address channel
        input awaddr, awprot, awvalid,
        output awready,
        // write data channel
        input wdata, wstrb, wvalid,
        output wready,
        // write response channel
        input bready,
        output bresp, bvalid,
        // read address channel
        input araddr, arprot, arvalid,
        output arready,
        // read data channel
        input rready,
        output rdata, rresp, rvalid
    );

    modport slave_id (
        input awid, wid, arid,
        output bid, rid
    );
endinterface
