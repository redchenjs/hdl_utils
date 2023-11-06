/*
 * axi4_stream_if.sv
 *
 *  Created on: 2023-11-06 01:27
 *      Author: Jack Chen <redchenjs@live.com>
 */

interface axi4_stream_if #(
    parameter   ID_WIDTH = 8,
    parameter DEST_WIDTH = 8,
    parameter DATA_WIDTH = 64,
    parameter USER_WIDTH = 64
);
    logic                    aclk;
    logic                    aresetn;
    // stream interface
    logic                    tvalid;
    logic                    tready;
    logic   [DATA_WIDTH-1:0] tdata;
    logic [DATA_WIDTH/8-1:0] tstrb;
    logic [DATA_WIDTH/8-1:0] tkeep;
    logic                    tlast;
    logic     [ID_WIDTH-1:0] tid;
    logic   [DEST_WIDTH-1:0] tdest;
    logic   [USER_WIDTH-1:0] tuser;

    modport master (
        input tready,
        output aclk, aresetn, tvalid, tdata, tstrb, tkeep, tlast, tid, tdest, tuser
    );

    modport slave (
        input aclk, aresetn, tvalid, tdata, tstrb, tkeep, tlast, tid, tdest, tuser,
        output tready
    );
endinterface
