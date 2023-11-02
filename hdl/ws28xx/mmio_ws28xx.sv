/*
 * mmio_ws28xx.sv
 *
 *  Created on: 2023-08-14 15:05
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module mmio_ws28xx #(
    parameter A_WIDTH = 8,
    parameter D_WIDTH = 32,
    parameter D_DEPTH = 256
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic               wr_en_i,
    input logic [A_WIDTH-1:0] wr_addr_i,
    input logic [D_WIDTH-1:0] wr_data_i,

    input  logic               rd_en_i,
    input  logic [A_WIDTH-1:0] rd_addr_i,
    output logic [D_WIDTH-1:0] rd_data_o,

    output logic ws28xx_o
);

typedef enum  {
    WS28XX_REG_CTRL_0 = 'h0,
    WS28XX_REG_CTRL_1 = 'h1,
    WS28XX_REG_CTRL_2 = 'h2,
    WS28XX_REG_RSVD_0 = 'h3,

    WS28XX_REG_IDX_MAX
} ws28xx_reg_t;

typedef struct packed {
    logic        done;
    logic [29:0] rsvd;
    logic        rst_n;
} ws28xx_ctrl_0_t;

typedef struct packed {
    logic [29:0] rsvd;
    logic        addr;
    logic        sync;
} ws28xx_ctrl_1_t;

typedef struct packed {
    logic [7:0] t1l;
    logic [7:0] t1h;
    logic [7:0] t0l;
    logic [7:0] t0h;
} ws28xx_ctrl_2_t;

ws28xx_ctrl_0_t ws28xx_ctrl_0;
ws28xx_ctrl_1_t ws28xx_ctrl_1;
ws28xx_ctrl_2_t ws28xx_ctrl_2;

logic out_done;
logic out_done_p;
logic out_done_n;

logic [D_WIDTH-1:0] regs[WS28XX_REG_IDX_MAX];

assign regs[WS28XX_REG_CTRL_0] = ws28xx_ctrl_0;
assign regs[WS28XX_REG_CTRL_1] = ws28xx_ctrl_1;
assign regs[WS28XX_REG_CTRL_2] = ws28xx_ctrl_2;
assign regs[WS28XX_REG_RSVD_0] = 'b0;

assign ws28xx_ctrl_0.rsvd = 'b0;
assign ws28xx_ctrl_1.rsvd = 'b0;

wire [8:0] ws28xx_t0s_time = ws28xx_ctrl_2.t0h + ws28xx_ctrl_2.t0l;
wire [8:0] ws28xx_t1s_time = ws28xx_ctrl_2.t1h + ws28xx_ctrl_2.t1l;

edge2en out_done_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(out_done),
    .pos_edge_o(out_done_p),
    .neg_edge_o(out_done_n)
);

ws28xx_core  #(
    .D_WIDTH(D_WIDTH),
    .D_DEPTH(D_DEPTH)
) ws28xx_core (
    .clk_i(clk_i),
    .rst_n_i(ws28xx_ctrl_0.rst_n),

    .out_sync_i(ws28xx_ctrl_1.sync),
    .out_done_o(out_done),

    .reg_t0h_time_i(ws28xx_ctrl_2.t0h),
    .reg_t0s_time_i(ws28xx_t0s_time),
    .reg_t1h_time_i(ws28xx_ctrl_2.t1h),
    .reg_t1s_time_i(ws28xx_t1s_time),

    .ram_wr_en_i(wr_en_i & wr_addr_i[10] ? (ws28xx_ctrl_1.addr ? 4'b1000 : 4'b0111) : 4'b0000),
    .ram_wr_addr_i(wr_addr_i[9:2]),
    .ram_wr_data_i(wr_data_i),

    .bit_code_o(ws28xx_o)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rd_data_o <= 'b0;

        ws28xx_ctrl_0.done  <= 'b0;
        ws28xx_ctrl_0.rst_n <= 'b0;

        ws28xx_ctrl_1.addr <= 'b0;
        ws28xx_ctrl_1.sync <= 'b0;

        ws28xx_ctrl_2 <= 'b0;
    end else begin
        rd_data_o <= rd_en_i ? regs[rd_addr_i[3:2]] : rd_data_o;

        if (wr_en_i & !wr_addr_i[10]) begin
            case (wr_addr_i[3:2])
                WS28XX_REG_CTRL_0: begin
                    ws28xx_ctrl_0.rst_n <= wr_data_i;
                end
                WS28XX_REG_CTRL_1: begin
                    {ws28xx_ctrl_1.addr, ws28xx_ctrl_1.sync} <= wr_data_i;
                end
                WS28XX_REG_CTRL_2: begin
                    ws28xx_ctrl_2 <= wr_data_i;
                end
                default: begin
                    ws28xx_ctrl_1.sync <= out_done_n ? 'b0 : ws28xx_ctrl_1.sync;
                end
            endcase
        end else begin
            ws28xx_ctrl_1.sync <= out_done_n ? 'b0 : ws28xx_ctrl_1.sync;
        end

        ws28xx_ctrl_0.done <= ws28xx_ctrl_1.sync ? 'b0 : (out_done_p ? 'b1 : ws28xx_ctrl_0.done);
    end
end

endmodule
