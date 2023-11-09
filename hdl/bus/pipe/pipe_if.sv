/*
 * pipe_if.sv
 *
 *  Created on: 2023-11-06 13:41
 *      Author: Jack Chen <redchenjs@live.com>
 */

interface pipe_if #(
    parameter int DATA_WIDTH = 32,
    parameter int USER_WIDTH = 64
);
    logic                  clk;
    logic                  rst_n;
    // pipe interface
    logic [DATA_WIDTH-1:0] data;
    logic [USER_WIDTH-1:0] user;
    logic                  last;
    logic                  valid;
    logic                  ready;

    modport in (
        input clk, rst_n, data, user, last, valid,
        output ready
    );

    modport out (
        input ready,
        output clk, rst_n, data, user, last, valid
    );
endinterface
