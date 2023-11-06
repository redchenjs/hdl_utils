/*
 * mmio_multiplexor.sv
 *
 *  Created on: 2021-08-22 18:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module mmio_multiplexor #(
    parameter A_WIDTH = 32,
    parameter D_WIDTH = 32,
    parameter SLV_NUM = 8
) (
    input logic [SLV_NUM-1:0] [1:0] [A_WIDTH-1:0] mmio_table,

    mmio_if.multiplexor #(
        .A_WIDTH(A_WIDTH),
        .D_WIDTH(D_WIDTH),
        .SLV_NUM(SLV_NUM)
    ) mmio_multiplexor
);

logic [$clog2(SLV_NUM)-1:0] rd_sel;

enc_64b #(
    .REG_OUT('b1)
) enc_64b (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i(mmio_multiplexor.rd_enx),
    .in_valid_i('b1),

    .out_data_o(rd_sel),
    .out_valid_o()
);

generate
    genvar i;

    for (i = 0; i < SLV_NUM; i++) begin : gen_multiplexor
        assign mmio_multiplexor.wr_enx[i] = (mmio_multiplexor.wr_addr & mmio_table[i][1]) == mmio_table[i][0];
        assign mmio_multiplexor.rd_enx[i] = (mmio_multiplexor.rd_addr & mmio_table[i][1]) == mmio_table[i][0];

        assign mmio_multiplexor.rd_data = mmio_multiplexor.rd_datax[rd_sel];
    end
endgenerate

endmodule
