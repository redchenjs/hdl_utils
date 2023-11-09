/*
 * mmio_if.sv
 *
 *  Created on: 2023-11-06 01:54
 *      Author: Jack Chen <redchenjs@live.com>
 */

interface mmio_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 64
);
    logic                    clk;
    logic                    rst_n;
    // write interface
    logic                    wr_en;
    logic   [ADDR_WIDTH-1:0] wr_addr;
    logic   [DATA_WIDTH-1:0] wr_data;
    logic [DATA_WIDTH/8-1:0] wr_byteen;
    // read interface
    logic                    rd_en;
    logic   [ADDR_WIDTH-1:0] rd_addr;
    logic   [DATA_WIDTH-1:0] rd_data;

    modport master (
        input rd_data,
        output clk, rst_n, wr_en, wr_addr, wr_data, wr_byteen, rd_en, rd_addr
    );

    modport slave (
        input clk, rst_n, wr_en, wr_addr, wr_data, wr_byteen, rd_en, rd_addr,
        output rd_data
    );
endinterface
