/*
 * apb_if.sv
 *
 *  Created on: 2023-11-03 04:04
 *      Author: Jack Chen <redchenjs@live.com>
 */

interface apb_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64,
    // bridge parameters
    parameter DEC_NUMBER = 16
);
    logic [ADDR_WIDTH-1:0] paddr;
    logic                  penable;
    logic                  psel;
    logic                  pwrite;
    logic [DATA_WIDTH-1:0] prdata;
    logic [DATA_WIDTH-1:0] pwdata;
    // bridge signals
    logic                  [DEC_NUMBER-1:0] pselx;
    logic [DEC_NUMBER-1:0] [DATA_WIDTH-1:0] prdatax;

    modport bridge (
        input prdata,
        output paddr, penable, pselx, pwrite, pwdata
    );

    modport slave (
        input paddr, penable, psel, pwrite, pwdata,
        output prdata
    );

    modport multiplexor (
        input pselx, prdatax,
        output prdata
    );
endinterface
