/*
 * apb_if.sv
 *
 *  Created on: 2023-11-03 04:04
 *      Author: Jack Chen <redchenjs@live.com>
 */

interface apb_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
);
    logic [ADDR_WIDTH-1:0] paddr;
    logic                  penable;
    logic                  psel;
    logic                  pwrite;
    logic [DATA_WIDTH-1:0] prdata;
    logic [DATA_WIDTH-1:0] pwdata;

    modport master (
        input prdata,
        output paddr, penable, pwrite, pwdata
    );

    modport slave (
        output prdata,
        input paddr, penable, psel, pwrite, pwdata
    );
endinterface
