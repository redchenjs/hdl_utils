/*
 * ahb_iopmp.sv
 *
 *  Created on: 2023-05-21 15:56
 *      Author: Jack Chen <redchenjs@live.com>
 */

import ahb_enum::*;

module ahb_iopmp #(
    parameter A_WIDTH = 32,
    parameter D_WIDTH = 32
) (
    input logic hclk_i,
    input logic hresetn_i,

    // Config port
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

    // Slave port 0
    input logic [A_WIDTH-1:0] s0_haddr_i,
    input logic         [3:0] s0_hprot_i,
    input logic         [2:0] s0_hsize_i,
    input logic         [1:0] s0_htrans_i,
    input logic         [2:0] s0_hburst_i,
    input logic               s0_hwrite_i,
    input logic [D_WIDTH-1:0] s0_hwdata_i,

    output logic         [1:0] s0_hresp_o,
    output logic               s0_hgrant_o,
    output logic               s0_hready_o,
    output logic [D_WIDTH-1:0] s0_hrdata_o,

    // Slave port 1
    input logic [A_WIDTH-1:0] s1_haddr_i,
    input logic         [3:0] s1_hprot_i,
    input logic         [2:0] s1_hsize_i,
    input logic         [1:0] s1_htrans_i,
    input logic         [2:0] s1_hburst_i,
    input logic               s1_hwrite_i,
    input logic [D_WIDTH-1:0] s1_hwdata_i,

    output logic         [1:0] s1_hresp_o,
    output logic               s1_hgrant_o,
    output logic               s1_hready_o,
    output logic [D_WIDTH-1:0] s1_hrdata_o,

    // Master port 0
    output logic               m0_hsel_o,
    output logic [A_WIDTH-1:0] m0_haddr_o,
    output logic         [3:0] m0_hprot_o,
    output logic         [2:0] m0_hsize_o,
    output logic         [1:0] m0_htrans_o,
    output logic         [2:0] m0_hburst_o,
    output logic               m0_hwrite_o,
    output logic [D_WIDTH-1:0] m0_hwdata_o,

    input logic         [1:0] m0_hresp_i,
    input logic               m0_hgrant_i,
    input logic               m0_hready_i,
    input logic [D_WIDTH-1:0] m0_hrdata_i,

    // Master port 1
    output logic               m1_hsel_o,
    output logic [A_WIDTH-1:0] m1_haddr_o,
    output logic         [3:0] m1_hprot_o,
    output logic         [2:0] m1_hsize_o,
    output logic         [1:0] m1_htrans_o,
    output logic         [2:0] m1_hburst_o,
    output logic               m1_hwrite_o,
    output logic [D_WIDTH-1:0] m1_hwdata_o,

    input logic         [1:0] m1_hresp_i,
    input logic               m1_hgrant_i,
    input logic               m1_hready_i,
    input logic [D_WIDTH-1:0] m1_hrdata_i
);

typedef struct packed {
    logic [31:24] en_w;
    logic [23:16] en_r;
    logic [15: 1] rsvd;
    logic         rst;
} pmp_ctrl_t;

typedef struct packed {
    logic [31:24] hit_w;
    logic [23:16] hit_r;
    logic [15: 2] rsvd;
    logic         err_w;
    logic         err_r;
} pmp_stat_t;

typedef struct packed {
    logic [31:0] addr;
} pmp_dump_t;

typedef struct packed {
    logic [31:0] mask;
    logic [31:0] base;
} pmp_conf_t;

pmp_ctrl_t pmp_ctrl_0;
pmp_stat_t pmp_stat_0;

pmp_dump_t pmp_dump_0_w;
pmp_dump_t pmp_dump_0_r;

pmp_conf_t pmp_conf_0_0;
pmp_conf_t pmp_conf_0_1;
pmp_conf_t pmp_conf_0_2;
pmp_conf_t pmp_conf_0_3;
pmp_conf_t pmp_conf_0_4;
pmp_conf_t pmp_conf_0_5;
pmp_conf_t pmp_conf_0_6;
pmp_conf_t pmp_conf_0_7;

pmp_ctrl_t pmp_ctrl_1;
pmp_stat_t pmp_stat_1;

pmp_dump_t pmp_dump_1_w;
pmp_dump_t pmp_dump_1_r;

pmp_conf_t pmp_conf_1_0;
pmp_conf_t pmp_conf_1_1;
pmp_conf_t pmp_conf_1_2;
pmp_conf_t pmp_conf_1_3;
pmp_conf_t pmp_conf_1_4;
pmp_conf_t pmp_conf_1_5;
pmp_conf_t pmp_conf_1_6;
pmp_conf_t pmp_conf_1_7;

logic [7:0] pmp_addr_0_hit_w;
logic [7:0] pmp_addr_0_hit_r;

logic [7:0] pmp_addr_1_hit_w;
logic [7:0] pmp_addr_1_hit_r;

logic               hsel_r;
logic [A_WIDTH-1:0] haddr_r;

wire rd_en = hsel_i & !hwrite_i;

assign hresp_o  = AHB_RESP_OKAY;
assign hready_o = 'b1;

assign m0_haddr_o  = s0_haddr_i;
assign m0_hprot_o  = s0_hprot_i;
assign m0_hsize_o  = s0_hsize_i;
assign m0_htrans_o = (|pmp_addr_0_hit_w) | (|pmp_addr_0_hit_r) ? s0_htrans_i : AHB_TRANS_IDLE;
assign m0_hburst_o = s0_hburst_i;
assign m0_hwrite_o = s0_hwrite_i;
assign m0_hwdata_o = s0_hwdata_i;

assign m1_haddr_o  = s1_haddr_i;
assign m1_hprot_o  = s1_hprot_i;
assign m1_hsize_o  = s1_hsize_i;
assign m1_htrans_o = (|pmp_addr_1_hit_w) | (|pmp_addr_1_hit_r) ? s1_htrans_i : AHB_TRANS_IDLE;
assign m1_hburst_o = s1_hburst_i;
assign m1_hwrite_o = s1_hwrite_i;
assign m1_hwdata_o = s1_hwdata_i;

assign s0_hresp_o  = m0_hresp_i;
assign s0_hgrant_o = m0_hgrant_i;
assign s0_hready_o = m0_hready_i;
assign s0_hrdata_o = m0_hrdata_i;

assign s1_hresp_o  = m1_hresp_i;
assign s1_hgrant_o = m1_hgrant_i;
assign s1_hready_o = m1_hready_i;
assign s1_hrdata_o = m1_hrdata_i;

assign pmp_addr_0_hit_w[0] = pmp_ctrl_0.en_w[0] & s0_hwrite_i & ((s0_haddr_i & pmp_conf_0_0.mask) == pmp_conf_0_0.base);
assign pmp_addr_0_hit_w[1] = pmp_ctrl_0.en_w[1] & s0_hwrite_i & ((s0_haddr_i & pmp_conf_0_1.mask) == pmp_conf_0_1.base);
assign pmp_addr_0_hit_w[2] = pmp_ctrl_0.en_w[2] & s0_hwrite_i & ((s0_haddr_i & pmp_conf_0_2.mask) == pmp_conf_0_2.base);
assign pmp_addr_0_hit_w[3] = pmp_ctrl_0.en_w[3] & s0_hwrite_i & ((s0_haddr_i & pmp_conf_0_3.mask) == pmp_conf_0_3.base);
assign pmp_addr_0_hit_w[4] = pmp_ctrl_0.en_w[4] & s0_hwrite_i & ((s0_haddr_i & pmp_conf_0_4.mask) == pmp_conf_0_4.base);
assign pmp_addr_0_hit_w[5] = pmp_ctrl_0.en_w[5] & s0_hwrite_i & ((s0_haddr_i & pmp_conf_0_5.mask) == pmp_conf_0_5.base);
assign pmp_addr_0_hit_w[6] = pmp_ctrl_0.en_w[6] & s0_hwrite_i & ((s0_haddr_i & pmp_conf_0_6.mask) == pmp_conf_0_6.base);
assign pmp_addr_0_hit_w[7] = pmp_ctrl_0.en_w[7] & s0_hwrite_i & ((s0_haddr_i & pmp_conf_0_7.mask) == pmp_conf_0_7.base);

assign pmp_addr_0_hit_r[0] = pmp_ctrl_0.en_r[0] & !s0_hwrite_i & ((s0_haddr_i & pmp_conf_0_0.mask) == pmp_conf_0_0.base);
assign pmp_addr_0_hit_r[1] = pmp_ctrl_0.en_r[1] & !s0_hwrite_i & ((s0_haddr_i & pmp_conf_0_1.mask) == pmp_conf_0_1.base);
assign pmp_addr_0_hit_r[2] = pmp_ctrl_0.en_r[2] & !s0_hwrite_i & ((s0_haddr_i & pmp_conf_0_2.mask) == pmp_conf_0_2.base);
assign pmp_addr_0_hit_r[3] = pmp_ctrl_0.en_r[3] & !s0_hwrite_i & ((s0_haddr_i & pmp_conf_0_3.mask) == pmp_conf_0_3.base);
assign pmp_addr_0_hit_r[4] = pmp_ctrl_0.en_r[4] & !s0_hwrite_i & ((s0_haddr_i & pmp_conf_0_4.mask) == pmp_conf_0_4.base);
assign pmp_addr_0_hit_r[5] = pmp_ctrl_0.en_r[5] & !s0_hwrite_i & ((s0_haddr_i & pmp_conf_0_5.mask) == pmp_conf_0_5.base);
assign pmp_addr_0_hit_r[6] = pmp_ctrl_0.en_r[6] & !s0_hwrite_i & ((s0_haddr_i & pmp_conf_0_6.mask) == pmp_conf_0_6.base);
assign pmp_addr_0_hit_r[7] = pmp_ctrl_0.en_r[7] & !s0_hwrite_i & ((s0_haddr_i & pmp_conf_0_7.mask) == pmp_conf_0_7.base);

assign pmp_addr_1_hit_w[0] = pmp_ctrl_1.en_w[0] & s0_hwrite_i & ((s1_haddr_i & pmp_conf_1_0.mask) == pmp_conf_1_0.base);
assign pmp_addr_1_hit_w[1] = pmp_ctrl_1.en_w[1] & s0_hwrite_i & ((s1_haddr_i & pmp_conf_1_1.mask) == pmp_conf_1_1.base);
assign pmp_addr_1_hit_w[2] = pmp_ctrl_1.en_w[2] & s0_hwrite_i & ((s1_haddr_i & pmp_conf_1_2.mask) == pmp_conf_1_2.base);
assign pmp_addr_1_hit_w[3] = pmp_ctrl_1.en_w[3] & s0_hwrite_i & ((s1_haddr_i & pmp_conf_1_3.mask) == pmp_conf_1_3.base);
assign pmp_addr_1_hit_w[4] = pmp_ctrl_1.en_w[4] & s0_hwrite_i & ((s1_haddr_i & pmp_conf_1_4.mask) == pmp_conf_1_4.base);
assign pmp_addr_1_hit_w[5] = pmp_ctrl_1.en_w[5] & s0_hwrite_i & ((s1_haddr_i & pmp_conf_1_5.mask) == pmp_conf_1_5.base);
assign pmp_addr_1_hit_w[6] = pmp_ctrl_1.en_w[6] & s0_hwrite_i & ((s1_haddr_i & pmp_conf_1_6.mask) == pmp_conf_1_6.base);
assign pmp_addr_1_hit_w[7] = pmp_ctrl_1.en_w[7] & s0_hwrite_i & ((s1_haddr_i & pmp_conf_1_7.mask) == pmp_conf_1_7.base);

assign pmp_addr_1_hit_r[0] = pmp_ctrl_1.en_r[0] & !s0_hwrite_i & ((s1_haddr_i & pmp_conf_1_0.mask) == pmp_conf_1_0.base);
assign pmp_addr_1_hit_r[1] = pmp_ctrl_1.en_r[1] & !s0_hwrite_i & ((s1_haddr_i & pmp_conf_1_1.mask) == pmp_conf_1_1.base);
assign pmp_addr_1_hit_r[2] = pmp_ctrl_1.en_r[2] & !s0_hwrite_i & ((s1_haddr_i & pmp_conf_1_2.mask) == pmp_conf_1_2.base);
assign pmp_addr_1_hit_r[3] = pmp_ctrl_1.en_r[3] & !s0_hwrite_i & ((s1_haddr_i & pmp_conf_1_3.mask) == pmp_conf_1_3.base);
assign pmp_addr_1_hit_r[4] = pmp_ctrl_1.en_r[4] & !s0_hwrite_i & ((s1_haddr_i & pmp_conf_1_4.mask) == pmp_conf_1_4.base);
assign pmp_addr_1_hit_r[5] = pmp_ctrl_1.en_r[5] & !s0_hwrite_i & ((s1_haddr_i & pmp_conf_1_5.mask) == pmp_conf_1_5.base);
assign pmp_addr_1_hit_r[6] = pmp_ctrl_1.en_r[6] & !s0_hwrite_i & ((s1_haddr_i & pmp_conf_1_6.mask) == pmp_conf_1_6.base);
assign pmp_addr_1_hit_r[7] = pmp_ctrl_1.en_r[7] & !s0_hwrite_i & ((s1_haddr_i & pmp_conf_1_7.mask) == pmp_conf_1_7.base);

always_ff @(posedge hclk_i or negedge hresetn_i)
begin
    if (!hresetn_i) begin
        hrdata_o <= 'b0;

        hsel_r  <= 'b0;
        haddr_r <= 'b0;

        pmp_ctrl_0 <= 'b0;
        pmp_stat_0 <= 'b0;

        pmp_dump_0_r <= 'b0;
        pmp_dump_0_w <= 'b0;

        pmp_conf_0_0 <= 'b0;
        pmp_conf_0_1 <= 'b0;
        pmp_conf_0_2 <= 'b0;
        pmp_conf_0_3 <= 'b0;
        pmp_conf_0_4 <= 'b0;
        pmp_conf_0_5 <= 'b0;
        pmp_conf_0_6 <= 'b0;
        pmp_conf_0_7 <= 'b0;

        pmp_ctrl_1 <= 'b0;
        pmp_stat_1 <= 'b0;

        pmp_dump_1_w <= 'b0;
        pmp_dump_1_r <= 'b0;

        pmp_conf_1_0 <= 'b0;
        pmp_conf_1_1 <= 'b0;
        pmp_conf_1_2 <= 'b0;
        pmp_conf_1_3 <= 'b0;
        pmp_conf_1_4 <= 'b0;
        pmp_conf_1_5 <= 'b0;
        pmp_conf_1_6 <= 'b0;
        pmp_conf_1_7 <= 'b0;
    end else begin
        hsel_r  <= hsel_i & hwrite_i;
        haddr_r <= haddr_i;

        if (pmp_ctrl_0.rst) begin
            pmp_ctrl_0.hit_w <= 'b0;
            pmp_ctrl_0.hit_r <= 'b0;

            pmp_ctrl_0.err_w <= 'b0;
            pmp_ctrl_0.err_r <= 'b0;

            pmp_dump_0_w.addr <= 'b0;
            pmp_dump_0_r.addr <= 'b0;
        end else begin
            pmp_ctrl_0.hit_w <= |pmp_addr_0_hit_w ? pmp_addr_0_hit_w : pmp_ctrl_0.hit_w;
            pmp_ctrl_0.hit_r <= |pmp_addr_0_hit_r ? pmp_addr_0_hit_r : pmp_ctrl_0.hit_r;

            pmp_ctrl_0.err_w <= !(|pmp_addr_0_hit_w) & (s0_htrans_i != AHB_TRANS_IDLE) ? 'b1 : pmp_ctrl_0.err_w;
            pmp_ctrl_0.err_r <= !(|pmp_addr_0_hit_r) & (s0_htrans_i != AHB_TRANS_IDLE) ? 'b1 : pmp_ctrl_0.err_r;

            pmp_dump_0_w.addr <= !(|pmp_addr_0_hit_w) & (s0_htrans_i != AHB_TRANS_IDLE) ? s0_haddr_i : pmp_dump_0_w.addr;
            pmp_dump_0_r.addr <= !(|pmp_addr_0_hit_r) & (s0_htrans_i != AHB_TRANS_IDLE) ? s0_haddr_i : pmp_dump_0_r.addr;
        end

        if (pmp_ctrl_1.rst) begin
            pmp_ctrl_1.hit_w <= 'b0;
            pmp_ctrl_1.hit_r <= 'b0;

            pmp_ctrl_1.err_w <= 'b0;
            pmp_ctrl_1.err_r <= 'b0;

            pmp_dump_1_w.addr <= 'b0;
            pmp_dump_1_r.addr <= 'b0;
        end else begin
            pmp_ctrl_1.hit_w <= |pmp_addr_1_hit_w ? pmp_addr_1_hit_w : pmp_ctrl_1.hit_w;
            pmp_ctrl_1.hit_r <= |pmp_addr_1_hit_r ? pmp_addr_1_hit_r : pmp_ctrl_1.hit_r;

            pmp_ctrl_1.err_w <= !(|pmp_addr_1_hit_w) & (s1_htrans_i != AHB_TRANS_IDLE) ? 'b1 : pmp_ctrl_1.err_w;
            pmp_ctrl_1.err_r <= !(|pmp_addr_1_hit_r) & (s1_htrans_i != AHB_TRANS_IDLE) ? 'b1 : pmp_ctrl_1.err_r;

            pmp_dump_1_w.addr <= !(|pmp_addr_1_hit_w) & (s1_htrans_i != AHB_TRANS_IDLE) ? s1_haddr_i : pmp_dump_1_w.addr;
            pmp_dump_1_r.addr <= !(|pmp_addr_1_hit_r) & (s1_htrans_i != AHB_TRANS_IDLE) ? s1_haddr_i : pmp_dump_1_r.addr;
        end

        if (hsel_r) begin
            case (haddr_r[7:0])
                8'h00: begin
                    pmp_ctrl_0.en_w <= hwdata_i[31:24];
                    pmp_ctrl_0.en_r <= hwdata_i[23:16];
                    pmp_ctrl_0.rst  <= hwdata_i[0];
                end
                8'h04: begin
                    pmp_ctrl_1.en_w <= hwdata_i[31:24];
                    pmp_ctrl_1.en_r <= hwdata_i[23:16];
                    pmp_ctrl_1.rst  <= hwdata_i[0];
                end
                8'h20: begin
                    pmp_conf_0_0.base <= hwdata_i;
                end
                8'h24: begin
                    pmp_conf_0_0.mask <= hwdata_i;
                end
                8'h28: begin
                    pmp_conf_0_1.base <= hwdata_i;
                end
                8'h2C: begin
                    pmp_conf_0_1.mask <= hwdata_i;
                end
                8'h30: begin
                    pmp_conf_0_2.base <= hwdata_i;
                end
                8'h34: begin
                    pmp_conf_0_2.mask <= hwdata_i;
                end
                8'h38: begin
                    pmp_conf_0_3.base <= hwdata_i;
                end
                8'h3C: begin
                    pmp_conf_0_3.mask <= hwdata_i;
                end
                8'h40: begin
                    pmp_conf_0_4.base <= hwdata_i;
                end
                8'h44: begin
                    pmp_conf_0_4.mask <= hwdata_i;
                end
                8'h48: begin
                    pmp_conf_0_5.base <= hwdata_i;
                end
                8'h4C: begin
                    pmp_conf_0_5.mask <= hwdata_i;
                end
                8'h50: begin
                    pmp_conf_0_6.base <= hwdata_i;
                end
                8'h54: begin
                    pmp_conf_0_6.mask <= hwdata_i;
                end
                8'h58: begin
                    pmp_conf_0_7.base <= hwdata_i;
                end
                8'h5C: begin
                    pmp_conf_0_7.mask <= hwdata_i;
                end
                8'h60: begin
                    pmp_conf_1_0.base <= hwdata_i;
                end
                8'h64: begin
                    pmp_conf_1_0.mask <= hwdata_i;
                end
                8'h68: begin
                    pmp_conf_1_1.base <= hwdata_i;
                end
                8'h6C: begin
                    pmp_conf_1_1.mask <= hwdata_i;
                end
                8'h70: begin
                    pmp_conf_1_2.base <= hwdata_i;
                end
                8'h74: begin
                    pmp_conf_1_2.mask <= hwdata_i;
                end
                8'h78: begin
                    pmp_conf_1_3.base <= hwdata_i;
                end
                8'h7C: begin
                    pmp_conf_1_3.mask <= hwdata_i;
                end
                8'h80: begin
                    pmp_conf_1_4.base <= hwdata_i;
                end
                8'h84: begin
                    pmp_conf_1_4.mask <= hwdata_i;
                end
                8'h88: begin
                    pmp_conf_1_5.base <= hwdata_i;
                end
                8'h8C: begin
                    pmp_conf_1_5.mask <= hwdata_i;
                end
                8'h90: begin
                    pmp_conf_1_6.base <= hwdata_i;
                end
                8'h94: begin
                    pmp_conf_1_6.mask <= hwdata_i;
                end
                8'h98: begin
                    pmp_conf_1_7.base <= hwdata_i;
                end
                8'h9C: begin
                    pmp_conf_1_7.mask <= hwdata_i;
                end
            endcase
        end

        if (rd_en) begin
            case (haddr_i[7:0])
                8'h00: begin
                    hrdata_o <= pmp_ctrl_0;
                end
                8'h04: begin
                    hrdata_o <= pmp_ctrl_1;
                end
                8'h08: begin
                    hrdata_o <= pmp_stat_0;
                end
                8'h0C: begin
                    hrdata_o <= pmp_stat_1;
                end
                8'h10: begin
                    hrdata_o <= pmp_dump_0_w;
                end
                8'h14: begin
                    hrdata_o <= pmp_dump_0_r;
                end
                8'h18: begin
                    hrdata_o <= pmp_dump_1_w;
                end
                8'h1C: begin
                    hrdata_o <= pmp_dump_1_r;
                end
                8'h20: begin
                    hrdata_o <= pmp_conf_0_0.base;
                end
                8'h24: begin
                    hrdata_o <= pmp_conf_0_0.mask;
                end
                8'h28: begin
                    hrdata_o <= pmp_conf_0_1.base;
                end
                8'h2C: begin
                    hrdata_o <= pmp_conf_0_1.mask;
                end
                8'h30: begin
                    hrdata_o <= pmp_conf_0_2.base;
                end
                8'h34: begin
                    hrdata_o <= pmp_conf_0_2.mask;
                end
                8'h38: begin
                    hrdata_o <= pmp_conf_0_3.base;
                end
                8'h3C: begin
                    hrdata_o <= pmp_conf_0_3.mask;
                end
                8'h40: begin
                    hrdata_o <= pmp_conf_0_4.base;
                end
                8'h44: begin
                    hrdata_o <= pmp_conf_0_4.mask;
                end
                8'h48: begin
                    hrdata_o <= pmp_conf_0_5.base;
                end
                8'h4C: begin
                    hrdata_o <= pmp_conf_0_5.mask;
                end
                8'h50: begin
                    hrdata_o <= pmp_conf_0_6.base;
                end
                8'h54: begin
                    hrdata_o <= pmp_conf_0_6.mask;
                end
                8'h58: begin
                    hrdata_o <= pmp_conf_0_7.base;
                end
                8'h5C: begin
                    hrdata_o <= pmp_conf_0_7.mask;
                end
                8'h60: begin
                    hrdata_o <= pmp_conf_1_0.base;
                end
                8'h64: begin
                    hrdata_o <= pmp_conf_1_0.mask;
                end
                8'h68: begin
                    hrdata_o <= pmp_conf_1_1.base;
                end
                8'h6C: begin
                    hrdata_o <= pmp_conf_1_1.mask;
                end
                8'h70: begin
                    hrdata_o <= pmp_conf_1_2.base;
                end
                8'h74: begin
                    hrdata_o <= pmp_conf_1_2.mask;
                end
                8'h78: begin
                    hrdata_o <= pmp_conf_1_3.base;
                end
                8'h7C: begin
                    hrdata_o <= pmp_conf_1_3.mask;
                end
                8'h80: begin
                    hrdata_o <= pmp_conf_1_4.base;
                end
                8'h84: begin
                    hrdata_o <= pmp_conf_1_4.mask;
                end
                8'h88: begin
                    hrdata_o <= pmp_conf_1_5.base;
                end
                8'h8C: begin
                    hrdata_o <= pmp_conf_1_5.mask;
                end
                8'h90: begin
                    hrdata_o <= pmp_conf_1_6.base;
                end
                8'h94: begin
                    hrdata_o <= pmp_conf_1_6.mask;
                end
                8'h98: begin
                    hrdata_o <= pmp_conf_1_7.base;
                end
                8'h9C: begin
                    hrdata_o <= pmp_conf_1_7.mask;
                end
                default: begin
                    hrdata_o <= 'b0;
                end
            endcase
        end
    end
end

endmodule
