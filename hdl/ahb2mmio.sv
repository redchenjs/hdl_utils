/*
 * ahb2mmio.sv
 *
 *  Created on: 2023-08-09 22:26
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import ahb_enum::*;

module ahb2mmio #(
    parameter A_WIDTH = 32,
    parameter D_WIDTH = 32,
    parameter IRQ_CNT = 0
) (
    input logic hclk_i,
    input logic hresetn_i,

    // ahb port
    input logic               hsel_i,
    input logic [A_WIDTH-1:0] haddr_i,
    input logic         [3:0] hprot_i,
    input logic         [2:0] hsize_i,
    input logic         [1:0] htrans_i,
    input logic         [2:0] hburst_i,
    input logic               hwrite_i,
    input logic [D_WIDTH-1:0] hwdata_i,

    output logic         [1:0] hresp_o,
    output logic               hready_o,
    output logic [D_WIDTH-1:0] hrdata_o,

    // mmio port
    output logic [D_WIDTH/8-1:0] wr_en_o,
    output logic   [A_WIDTH-1:0] wr_addr_o,
    output logic   [D_WIDTH-1:0] wr_data_o,

    output logic               rd_en_o,
    output logic [A_WIDTH-1:0] rd_addr_o,
    input  logic [D_WIDTH-1:0] rd_data_i
);

logic [D_WIDTH/8-1:0] hsel_r;
logic   [A_WIDTH-1:0] haddr_r;
logic   [D_WIDTH-1:0] hwdata_r;

logic [$clog2(D_WIDTH/8):0] [D_WIDTH/8-1:0] hsel_mux;

assign wr_en_o   = hsel_r;
assign wr_addr_o = haddr_r;
assign wr_data_o = hwdata_r;

assign rd_en_o   = hsel_i & !hwrite_i & (htrans_i != AHB_TRANS_IDLE);
assign rd_addr_o = haddr_i;

assign hresp_o  = AHB_RESP_OKAY;
assign hready_o = 'b1;
assign hrdata_o = rd_data_i;

generate
    genvar i;

    for (i = 0; i < $clog2(D_WIDTH/8)+1; i++) begin: gen_en_sel
        genvar j;

        for (j = 0; j < D_WIDTH/8; j++) begin: gen_en_bit
            assign hsel_mux[i][j] = (j < (1 << i));
        end
    end
endgenerate

always_ff @(posedge hclk_i or negedge hresetn_i)
begin
    if (!hresetn_i) begin
        hsel_r   <= 'b0;
        haddr_r  <= 'b0;
        hwdata_r <= 'b0;
    end else begin
        case (htrans_i)
            AHB_TRANS_IDLE:   hsel_r <= 'b0;
            AHB_TRANS_BUSY:   hsel_r <= 'b0;
            AHB_TRANS_NONSEQ: hsel_r <= (hsel_i & hwrite_i) ? hsel_mux[hsize_i] : 'b0;
            AHB_TRANS_SEQ:    hsel_r <= (hsel_i & hwrite_i) ? hsel_mux[hsize_i] : 'b0;
            default:          hsel_r <= 'b0;
        endcase

        haddr_r  <= haddr_i;
        hwdata_r <= hwdata_i;
    end
end

endmodule
