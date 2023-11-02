/*
 * ws28xx_core.sv
 *
 *  Created on: 2020-04-06 23:09
 *      Author: Jack Chen <redchenjs@live.com>
 */

module ws28xx_core #(
    parameter D_WIDTH = 32,
    parameter D_DEPTH = 256
) (
    input logic clk_i,
    input logic rst_n_i,

    input  logic out_sync_i,
    output logic out_done_o,

    input logic [7:0] reg_t0h_time_i,
    input logic [8:0] reg_t0s_time_i,
    input logic [7:0] reg_t1h_time_i,
    input logic [8:0] reg_t1s_time_i,

    input logic  [3:0] ram_wr_en_i,
    input logic  [7:0] ram_wr_addr_i,
    input logic [31:0] ram_wr_data_i,

    output logic bit_code_o
);

logic bit_valid, bit_ready, bit_data;

logic [$clog2(D_DEPTH)-1:0] ram_rd_addr;
logic         [D_WIDTH-1:0] ram_rd_data;

ram_tp #(
    .I_WIDTH(D_WIDTH),
    .I_DEPTH(D_DEPTH),
    .O_WIDTH(D_WIDTH),
    .O_DEPTH(D_DEPTH),
    .BYTE_EN(1),
    .REG_OUT(1)
) ram_tp (
    .wr_clk_i(clk_i),

    .wr_en_i(ram_wr_en_i),
    .wr_addr_i(ram_wr_addr_i),
    .wr_data_i(ram_wr_data_i),

    .rd_clk_i(clk_i),

    .rd_en_i('b1),
    .rd_addr_i(ram_rd_addr),
    .rd_data_o(ram_rd_data)
);

ws28xx_ctl ws28xx_ctl(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .out_sync_i(out_sync_i),
    .out_done_o(out_done_o),

    .bit_data_o(bit_data),
    .bit_valid_o(bit_valid),
    .bit_ready_i(bit_ready),

    .ram_rd_addr_o(ram_rd_addr),
    .ram_rd_data_i(ram_rd_data)
);

ws28xx_gen ws28xx_gen(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .bit_data_i(bit_data),
    .bit_valid_i(bit_valid),
    .bit_ready_o(bit_ready),

    .reg_t0h_time_i(reg_t0h_time_i),
    .reg_t0s_time_i(reg_t0s_time_i),
    .reg_t1h_time_i(reg_t1h_time_i),
    .reg_t1s_time_i(reg_t1s_time_i),

    .bit_code_o(bit_code_o)
);

endmodule
