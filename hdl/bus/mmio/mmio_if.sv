/*
 * mmio_if.sv
 *
 *  Created on: 2023-11-06 01:54
 *      Author: Jack Chen <redchenjs@live.com>
 */

interface mmio_if #(
    parameter A_WIDTH = 32,
    parameter D_WIDTH = 32,
    parameter SLV_NUM = 1
);
    // write interface
    logic                 wr_en;
    logic   [A_WIDTH-1:0] wr_addr;
    logic   [D_WIDTH-1:0] wr_data;
    logic [D_WIDTH/8-1:0] wr_byteen;
    // read interface
    logic               rd_en;
    logic [A_WIDTH-1:0] rd_addr;
    logic [D_WIDTH-1:0] rd_data;
    // multiplexor interface
    logic               [SLV_NUM-1:0] wr_enx;
    logic               [SLV_NUM-1:0] rd_enx;
    logic [SLV_NUM-1:0] [D_WIDTH-1:0] rd_datax;

    modport master (
        input rd_data,
        output wr_en, wr_addr, wr_data, wr_byteen, rd_en, rd_addr
    );

    modport slave (
        input wr_en, wr_addr, wr_data, wr_byteen, rd_en, rd_addr,
        output rd_data
    );

    modport multiplexor (
        input wr_addr, rd_addr, rd_datax,
        output wr_enx, rd_enx, rd_data
    );
endinterface
