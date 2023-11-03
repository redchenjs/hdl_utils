/*
 * apb4_if.sv
 *
 *  Created on: 2023-11-04 02:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

import apb4_pkg::*;

interface apb4_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    // bridge parameters
    parameter DEC_NUMBER = 1
);
    logic   [ADDR_WIDTH-1:0] paddr;
    ahb_prot_t               pprot;
    logic                    penable;
    logic                    psel;
    logic                    pwrite;
    logic   [DATA_WIDTH-1:0] prdata;
    logic   [DATA_WIDTH-1:0] pwdata;
    logic [DATA_WIDTH/8-1:0] pstrb;
    logic                    pready;
    logic                    pslverr;
    // bridge signals
    logic                  [DEC_NUMBER-1:0] pselx;
    logic [DEC_NUMBER-1:0] [DATA_WIDTH-1:0] prdatax;
    logic                  [DEC_NUMBER-1:0] preadyx;
    logic                  [DEC_NUMBER-1:0] pslverrx;

    modport bridge (
        input prdata, pready, pslverr,
        output paddr, penable, pselx, pwrite, pwdata
    );

    modport slave (
        input paddr, penable, psel, pwrite, pwdata,
        output prdata, pready, pslverr
    );

    modport multiplexor (
        input pselx, prdatax, preadyx, pslverrx,
        output prdata, pready, pslverr
    );
endinterface
