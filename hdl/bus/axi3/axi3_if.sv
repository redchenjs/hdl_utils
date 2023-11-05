/*
 * axi3_if.sv
 *
 *  Created on: 2023-11-05 23:10
 *      Author: Jack Chen <redchenjs@live.com>
 */

import axi3_pkg::*;

interface axi3_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
);
    // write address channel
    axi_id_t               awid;
    logic [ADDR_WIDTH-1:0] awaddr;
    axi_len_t              awlen;
    axi_size_t             awsize;
    axi_burst_t            awburst;
    axi_lock_t             awlock;
    axi_cache_t            awcache;
    axi_prot_t             awprot;
    logic                  awvalid;
    logic                  awready;
    // write data channel
    axi_id_t                 wid;
    logic   [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH/8-1:0] wstrb;
    logic                    wlast;
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
    axi_len_t              arlen;
    axi_size_t             arsize;
    axi_burst_t            arburst;
    axi_lock_t             arlock;
    axi_cache_t            arcache;
    axi_prot_t             arprot;
    logic                  arvalid;
    logic                  arready;
    // read data channel
    axi_id_t               rid;
    logic [DATA_WIDTH-1:0] rdata;
    axi_resp_t             rresp;
    logic                  rlast;
    logic                  rvalid;
    logic                  rready;
    // low-power interface
    logic         csysreq;
    logic         csysack;
    axi_cactive_t cactive;

    modport master (
        // write address channel
        input awready,
        output awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awvalid,
        // write data channel
        input wready,
        output wid, wdata, wstrb, wlast, wvalid,
        // write response channel
        input bid, bresp, bvalid,
        output bready,
        // read address channel
        input arready,
        output arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arvalid,
        // read data channel
        input rid, rdata, rresp, rlast, rvalid,
        output rready
    );

    modport slave (
        // write address channel
        input awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awvalid,
        output awready,
        // write data channel
        input wid, wdata, wstrb, wlast, wvalid,
        output wready,
        // write response channel
        input bready,
        output bid, bresp, bvalid,
        // read address channel
        input arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arvalid,
        output arready,
        // read data channel
        input rready,
        output rid, rdata, rresp, rlast, rvalid
    );

    modport lpi (
        input csysreq,
        output csysack, cactive
    );
endinterface
