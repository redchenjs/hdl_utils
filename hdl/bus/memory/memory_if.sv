/*
 * memory_if.sv
 *
 *  Created on: 2023-11-06 01:54
 *      Author: Jack Chen <redchenjs@live.com>
 */

interface memory_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
);
    // write interface
    logic                    wr_en;
    logic                    wr_done;
    logic   [ADDR_WIDTH-1:0] wr_addr;
    logic   [DATA_WIDTH-1:0] wr_data;
    logic [DATA_WIDTH/8-1:0] wr_byteen;
    // read interface
    logic                    rd_en;
    logic                    rd_done;
    logic   [ADDR_WIDTH-1:0] rd_addr;
    logic   [DATA_WIDTH-1:0] rd_data;

    modport master (
        input wr_done, rd_done, rd_data,
        output wr_en, wr_addr, wr_data, wr_byteen, rd_en, rd_addr
    );

    modport slave (
        input wr_en, wr_addr, wr_data, wr_byteen, rd_en, rd_addr,
        output wr_done, rd_done, rd_data
    );
endinterface
