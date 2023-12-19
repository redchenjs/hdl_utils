/*
 * stream_if.sv
 *
 *  Created on: 2023-11-06 13:41
 *      Author: Jack Chen <redchenjs@live.com>
 */

interface stream_if #(
    parameter int CTRL_WIDTH = 32,
    parameter int DATA_WIDTH = 32
);
    logic [CTRL_WIDTH-1:0] ctrl;
    logic [DATA_WIDTH-1:0] data;
    logic                  last;
    logic                  valid;
    logic                  ready;

    modport master (
        input ready,
        output ctrl, data, last, valid
    );

    modport slave (
        input ctrl, data, last, valid,
        output ready
    );
endinterface
