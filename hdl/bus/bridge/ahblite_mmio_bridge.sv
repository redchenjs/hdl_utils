/*
 * ahblite_mmio_bridge.sv
 *
 *  Created on: 2023-08-09 22:26
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import ahb_lite_pkg::*;

module ahblite_mmio_bridge #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    ahb_lite_if.slave s_ahblite,
    mmio_if.master    m_mmio
);

logic                  hsel_r;
logic                  hsel_w;
logic [ADDR_WIDTH-1:0] haddr_w;

logic                                             [DATA_WIDTH/8-1:0] byteen;
logic [DATA_WIDTH/8-1:0] [$clog2(DATA_WIDTH/8):0] [DATA_WIDTH/8-1:0] byteen_mux;

assign m_mmio.clk   = s_ahblite.hclk;
assign m_mmio.rst_n = s_ahblite.hresetn;

assign m_mmio.wr_en     = hsel_w;
assign m_mmio.wr_addr   = haddr_w;
assign m_mmio.wr_data   = s_ahblite.hwdata;
assign m_mmio.wr_byteen = byteen;

assign m_mmio.rd_en   = hsel_r;
assign m_mmio.rd_addr = s_ahblite.haddr;

assign s_ahblite.hresp  = AHB_RESP_OKAY;
assign s_ahblite.hready = 'b1;
assign s_ahblite.hrdata = m_mmio.rd_data;

generate
    genvar i;

    for (i = 0; i < $clog2(DATA_WIDTH/8)+1; i++) begin: gen_byteen_sel
        genvar j;

        for (j = 0; j < DATA_WIDTH/8; j++) begin: gen_byteen_bit
            genvar k;

            for (k = 0; k < DATA_WIDTH/8; k++) begin: gen_byteen_sft
                assign byteen_mux[k][i][j] = (j < ((1 << i) + k)) & (j >= k);
            end
        end
    end
endgenerate

always_comb begin
    case (s_ahblite.htrans)
        AHB_TRANS_IDLE,
        AHB_TRANS_BUSY: begin
            hsel_r = 'b0;
        end
        AHB_TRANS_NONSEQ,
        AHB_TRANS_SEQ: begin
            hsel_r = s_ahblite.hsel & !s_ahblite.hwrite;
        end
        default: begin
            hsel_r = 'b0;
        end
    endcase
end

always_ff @(posedge s_ahblite.hclk or negedge s_ahblite.hresetn)
begin
    if (!s_ahblite.hresetn) begin
        byteen <= 'b0;

        hsel_w  <= 'b0;
        haddr_w <= 'b0;
    end else begin
        case (s_ahblite.htrans)
            AHB_TRANS_IDLE,
            AHB_TRANS_BUSY: begin
                byteen <= 'b0;

                hsel_w  <= 'b0;
                haddr_w <= 'b0;
            end
            AHB_TRANS_NONSEQ,
            AHB_TRANS_SEQ: begin
                byteen <= s_ahblite.hsel & s_ahblite.hwrite ? byteen_mux[s_ahblite.haddr[$clog2(DATA_WIDTH/8)-1:0]][s_ahblite.hsize] : 'b0;

                hsel_w  <= s_ahblite.hsel & s_ahblite.hwrite;
                haddr_w <= s_ahblite.haddr;
            end
            default: begin
                byteen <= 'b0;

                hsel_w  <= 'b0;
                haddr_w <= 'b0;
            end
        endcase
    end
end

endmodule
