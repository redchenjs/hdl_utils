/*
 * ahb2mmio.sv
 *
 *  Created on: 2023-08-09 22:26
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import ahb_pkg::*;

module ahb2mmio #(
    parameter A_WIDTH = 32,
    parameter D_WIDTH = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    ahb_if.slave #(
        .A_WIDTH(A_WIDTH),
        .D_WIDTH(D_WIDTH)
    ) s_ahb,

    mmio_if.master #(
        .A_WIDTH(A_WIDTH),
        .D_WIDTH(D_WIDTH)
    ) m_mmio
);

logic                 hsel_r;
logic [D_WIDTH/8-1:0] hsel_w;
logic   [A_WIDTH-1:0] haddr_w;

logic [D_WIDTH/8-1:0] [$clog2(D_WIDTH/8):0] [D_WIDTH/8-1:0] hsel_mux;

assign m_mmio.wr_en     = 'b1;
assign m_mmio.wr_addr   = haddr_w;
assign m_mmio.wr_data   = s_ahb.hwdata;
assign m_mmio.wr_byteen = hsel_w;

assign m_mmio.rd_en   = hsel_r;
assign m_mmio.rd_addr = s_ahb.haddr;

assign s_ahb.hresp  = AHB_RESP_OKAY;
assign s_ahb.hready = 'b1;
assign s_ahb.hrdata = m_mmio.rd_data;

generate
    genvar i;

    for (i = 0; i < $clog2(D_WIDTH/8)+1; i++) begin: gen_en_sel
        genvar j;

        for (j = 0; j < D_WIDTH/8; j++) begin: gen_en_bit
            genvar k;

            for (k = 0; k < D_WIDTH/8; k++) begin: gen_en_sft
                assign hsel_mux[k][i][j] =(j < ((1 << i) + k)) & (j >= k);
            end
        end
    end
endgenerate

always_comb begin
    case (s_ahb.htrans)
        AHB_TRANS_IDLE,
        AHB_TRANS_BUSY: begin
            hsel_r = 'b0;
        end
        AHB_TRANS_NONSEQ,
        AHB_TRANS_SEQ: begin
            hsel_r = s_ahb.hsel & !s_ahb.hwrite;
        end
        default: begin
            hsel_r = 'b0;
        end
    endcase
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        hsel_w  <= 'b0;
        haddr_w <= 'b0;
    end else begin
        case (s_ahb.htrans)
            AHB_TRANS_IDLE,
            AHB_TRANS_BUSY: begin
                hsel_w  <= 'b0;
                haddr_w <= 'b0;
            end
            AHB_TRANS_NONSEQ,
            AHB_TRANS_SEQ: begin
                hsel_w  <= s_ahb.hsel & s_ahb.hwrite ? hsel_mux[s_ahb.haddr[$clog2(D_WIDTH/8)-1:0]][s_ahb.hsize] : 'b0;
                haddr_w <= s_ahb.haddr;
            end
            default: begin
                hsel_w  <= 'b0;
                haddr_w <= 'b0;
            end
        endcase
    end
end

endmodule
