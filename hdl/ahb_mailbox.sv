/*
 * ahb_mailbox.sv
 *
 *  Created on: 2023-05-15 21:28
 *      Author: Jack Chen <redchenjs@live.com>
 */

import ahb_enum::*;

module ahb_mailbox #(
    parameter A_WIDTH = 32,
    parameter D_WIDTH = 32
) (
    input logic hclk_i,
    input logic hresetn_i,

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

    output logic irq_o
);

typedef struct packed {
    logic         intr;
    logic         full; // 0: empty, 1: full
    logic   [6:0] rsvd;
    logic  [14:0] size;
    logic   [7:0] id;
} mbox_ctrl_t;

mbox_ctrl_t mbox_ctrl_0;
mbox_ctrl_t mbox_ctrl_1;

logic               ram_hsel;
logic         [1:0] ram_hresp;
logic               ram_hready;
logic [D_WIDTH-1:0] ram_hrdata;

logic [D_WIDTH-1:0] reg_hrdata;

logic               reg_hsel_r;
logic [A_WIDTH-1:0] reg_haddr_r;

wire rd_en = !haddr_i[15] & hsel_i & !hwrite_i;

wire [1:0] reg_hresp  = AHB_RESP_OKAY;
wire       reg_hready = 'b1;

assign hresp_o  = ram_hsel ? ram_hresp  : reg_hresp;
assign hready_o = ram_hsel ? ram_hready : reg_hready;
assign hrdata_o = ram_hsel ? ram_hrdata : reg_hrdata;

assign irq_o = mbox_ctrl_0.intr | mbox_ctrl_1.intr;

ahb_ram #(
    .A_WIDTH(A_WIDTH),
    .D_WIDTH(D_WIDTH),
    .D_DEPTH(8192)
) ahb_ram (
    .hclk_i(hclk_i),
    .hresetn_i(hresetn_i),

    .hsel_i(hsel_i),
    .haddr_i(haddr_i),
    .hprot_i(hprot_i),
    .hsize_i(hsize_i),
    .htrans_i(htrans_i),
    .hburst_i(hburst_i),
    .hwrite_i(hwrite_i & haddr_i[15]),
    .hwdata_i(hwdata_i),

    .hresp_o(ram_hresp),
    .hready_o(ram_hready),
    .hrdata_o(ram_hrdata)
);

always_ff @(posedge hclk_i or negedge hresetn_i)
begin
    if (!hresetn_i) begin
        ram_hsel <= 'b0;

        reg_hsel_r  <= 'b0;
        reg_haddr_r <= 'b0;

        reg_hrdata <= 'b0;

        mbox_ctrl_0 <= 'b0;
        mbox_ctrl_1 <= 'b0;
    end else begin
        ram_hsel <= haddr_i[15] & hsel_i;

        reg_hsel_r  <= !haddr_i[15] & hsel_i & hwrite_i;
        reg_haddr_r <=  haddr_i;

        if (reg_hsel_r) begin
            case (reg_haddr_r[7:0])
                8'h00: begin
                    mbox_ctrl_0 <= hwdata_i;
                end
                8'h04: begin
                    mbox_ctrl_1 <= hwdata_i;
                end
            endcase
        end

        if (rd_en) begin
            case (haddr_i[7:0])
                8'h00: begin
                    reg_hrdata <= mbox_ctrl_0;
                end
                8'h04: begin
                    reg_hrdata <= mbox_ctrl_1;
                end
                default: begin
                    reg_hrdata <= 'b0;
                end
            endcase
        end
    end
end

endmodule
