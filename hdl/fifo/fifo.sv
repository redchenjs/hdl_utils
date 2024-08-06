/*
 * fifo.sv
 *
 *  Created on: 2022-12-22 23:34
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module fifo #(
    parameter int I_WIDTH = 64,
    parameter int I_DEPTH = 32,
    parameter int O_WIDTH = 32,
    parameter int O_DEPTH = 64,
    parameter bit T_ASYNC = 0,
    parameter bit DBG_OUT = 0,
    parameter bit REG_OUT = 1
) (
    input logic wr_clk_i,
    input logic wr_rst_n_i,

    input  logic                     wr_en_i,
    input  logic       [I_WIDTH-1:0] wr_data_i,
    output logic                     wr_full_o,
    output logic [$clog2(I_DEPTH):0] wr_free_o,

    input logic rd_clk_i,
    input logic rd_rst_n_i,

    input  logic                     rd_en_i,
    output logic       [O_WIDTH-1:0] rd_data_o,
    output logic                     rd_empty_o,
    output logic [$clog2(O_DEPTH):0] rd_avail_o
);

logic [$clog2(I_DEPTH):0] wr_addr_w; // [Write Region] Write Address (Bin)
logic [$clog2(I_DEPTH):0] wr_addr_g; // [Write Region] Write Address (Gray)
logic [$clog2(I_DEPTH):0] wr_addr_s; // [Read  Region] Write Address (Gray)
logic [$clog2(I_DEPTH):0] wr_addr_r; // [Read  Region] Write Address (Bin)

logic [$clog2(O_DEPTH):0] rd_addr_r; // [Read  Region] Read Address (Bin)
logic [$clog2(O_DEPTH):0] rd_addr_g; // [Read  Region] Read Address (Gray)
logic [$clog2(O_DEPTH):0] rd_addr_s; // [Write Region] Read Address (Gray)
logic [$clog2(O_DEPTH):0] rd_addr_w; // [Write Region] Read Address (Bin)

generate
    if (O_WIDTH >= I_WIDTH) begin
        // Read Data Width > Write Data Width : Extend Read Address
        wire [$clog2(I_DEPTH):0] rd_addr_r_ext  = {rd_addr_r, {$clog2(I_DEPTH/O_DEPTH){1'b0}}};
        wire [$clog2(I_DEPTH):0] rd_addr_g_ext  = {rd_addr_g, {$clog2(I_DEPTH/O_DEPTH){1'b0}}};
        wire [$clog2(I_DEPTH):0] rd_addr_s_ext  = {rd_addr_s, {$clog2(I_DEPTH/O_DEPTH){1'b0}}};
        wire [$clog2(I_DEPTH):0] rd_addr_w_ext  = {rd_addr_w, {$clog2(I_DEPTH/O_DEPTH){1'b0}}};
        wire [$clog2(I_DEPTH):0] rd_avail_r_ext = {wr_addr_r[$clog2(I_DEPTH)] ^ rd_addr_r_ext[$clog2(I_DEPTH)], wr_addr_r[$clog2(I_DEPTH)-1:0]} - {1'b0, rd_addr_r_ext[$clog2(I_DEPTH)-1:0]};

        assign wr_full_o = (rd_addr_s_ext == {~wr_addr_g[$clog2(I_DEPTH):$clog2(I_DEPTH)-T_ASYNC], wr_addr_g[$clog2(I_DEPTH)-T_ASYNC-1:0]});
        assign wr_free_o = DBG_OUT ? (I_DEPTH - ({wr_addr_w[$clog2(I_DEPTH)] ^ rd_addr_w_ext[$clog2(I_DEPTH)], wr_addr_w[$clog2(I_DEPTH)-1:0]} - {1'b0, rd_addr_w_ext[$clog2(I_DEPTH)-1:0]})) : 'b0;

        assign rd_empty_o = (rd_addr_g_ext == wr_addr_s);
        assign rd_avail_o = DBG_OUT ? ({{$clog2(I_DEPTH/O_DEPTH){1'b0}}, rd_avail_r_ext[$clog2(I_DEPTH):$clog2(I_DEPTH/O_DEPTH)]}) : 'b0;
    end else begin
        // Read Data Width < Write Data Width : Extend Write Address
        wire [$clog2(O_DEPTH):0] wr_addr_w_ext = {wr_addr_w, {$clog2(O_DEPTH/I_DEPTH){1'b0}}};
        wire [$clog2(O_DEPTH):0] wr_addr_g_ext = {wr_addr_g, {$clog2(O_DEPTH/I_DEPTH){1'b0}}};
        wire [$clog2(O_DEPTH):0] wr_addr_s_ext = {wr_addr_s, {$clog2(O_DEPTH/I_DEPTH){1'b0}}};
        wire [$clog2(O_DEPTH):0] wr_addr_r_ext = {wr_addr_r, {$clog2(O_DEPTH/I_DEPTH){1'b0}}};
        wire [$clog2(O_DEPTH):0] wr_free_w_ext = (O_DEPTH - ({wr_addr_w_ext[$clog2(O_DEPTH)] ^ rd_addr_w[$clog2(O_DEPTH)], wr_addr_w_ext[$clog2(O_DEPTH)-1:0]} - {1'b0, rd_addr_w[$clog2(O_DEPTH)-1:0]}));

        assign wr_full_o = (rd_addr_s == {~wr_addr_g_ext[$clog2(O_DEPTH):$clog2(O_DEPTH)-T_ASYNC], wr_addr_g_ext[$clog2(O_DEPTH)-T_ASYNC-1:0]});
        assign wr_free_o = DBG_OUT ? ({{$clog2(O_DEPTH/I_DEPTH){1'b0}}, wr_free_w_ext[$clog2(O_DEPTH):$clog2(O_DEPTH/I_DEPTH)]}) : 'b0;

        assign rd_empty_o = (rd_addr_g == wr_addr_s_ext);
        assign rd_avail_o = DBG_OUT ? ({wr_addr_r_ext[$clog2(O_DEPTH)] ^ rd_addr_r[$clog2(O_DEPTH)], wr_addr_r_ext[$clog2(O_DEPTH)-1:0]} - {1'b0, rd_addr_r[$clog2(O_DEPTH)-1:0]}) : 'b0;
    end
endgenerate

if (T_ASYNC) begin
    // [Write -> Read] Bin To Gray
    bin2gray #(
        .D_WIDTH($clog2(I_DEPTH)+1),
        .REG_OUT(1)
    ) bin2gray_w2r (
        .clk_i(wr_clk_i),
        .rst_n_i(wr_rst_n_i),

        .in_data_i(wr_addr_w),
        .in_valid_i('b1),

        .out_data_o(wr_addr_g),
        .out_valid_o()
    );

    // [Write -> Read] Two-Stage Sync
    data_sync #(
        .S_STAGE(2),
        .I_VALUE(0),
        .D_WIDTH($clog2(I_DEPTH)+1)
    ) data_sync_w2r (
        .clk_i(rd_clk_i),
        .rst_n_i(rd_rst_n_i),

        .data_i(wr_addr_g),
        .data_o(wr_addr_s)
    );

    if (DBG_OUT) begin
        // [Write -> Read] Gray To Bin (FOR DEBUG OUTPUT)
        gray2bin #(
            .D_WIDTH($clog2(I_DEPTH)+1),
            .REG_OUT(0)
        ) gray2bin_w2r (
            .clk_i(rd_clk_i),
            .rst_n_i(rd_rst_n_i),

            .in_data_i(wr_addr_s),
            .in_valid_i('b1),

            .out_data_o(wr_addr_r),
            .out_valid_o()
        );
    end

    // [Read -> Write] Bin To Gray
    bin2gray #(
        .D_WIDTH($clog2(O_DEPTH)+1),
        .REG_OUT(1)
    ) bin2gray_r2w (
        .clk_i(rd_clk_i),
        .rst_n_i(rd_rst_n_i),

        .in_data_i(rd_addr_r),
        .in_valid_i('b1),

        .out_data_o(rd_addr_g),
        .out_valid_o()
    );

    // [Read -> Write] Two-Stage Sync
    data_sync #(
        .S_STAGE(2),
        .I_VALUE(0),
        .D_WIDTH($clog2(O_DEPTH)+1)
    ) data_sync_r2w (
        .clk_i(wr_clk_i),
        .rst_n_i(wr_rst_n_i),

        .data_i(rd_addr_g),
        .data_o(rd_addr_s)
    );

    if (DBG_OUT) begin
        // [Read -> Write] Gray To Bin (FOR DEBUG OUTPUT)
        gray2bin #(
            .D_WIDTH($clog2(O_DEPTH)+1),
            .REG_OUT(0)
        ) gray2bin_r2w (
            .clk_i(wr_clk_i),
            .rst_n_i(wr_rst_n_i),

            .in_data_i(rd_addr_s),
            .in_valid_i('b1),

            .out_data_o(rd_addr_w),
            .out_valid_o()
        );
    end
end else begin
    // No CDC Sync
    assign wr_addr_g = wr_addr_w;
    assign wr_addr_s = wr_addr_w;
    assign wr_addr_r = wr_addr_w;

    assign rd_addr_g = rd_addr_r;
    assign rd_addr_s = rd_addr_r;
    assign rd_addr_w = rd_addr_r;
end

// Two-Port Memory
ram_tp #(
    .I_WIDTH(I_WIDTH),
    .I_DEPTH(I_DEPTH),
    .O_WIDTH(O_WIDTH),
    .O_DEPTH(O_DEPTH),
    .BYTE_EN(0),
    .REG_OUT(REG_OUT)
) ram_tp (
    .wr_clk_i(wr_clk_i),

    .wr_en_i(wr_en_i & ~wr_full_o),
    .wr_addr_i(wr_addr_w[$clog2(I_DEPTH)-1:0]),
    .wr_data_i(wr_data_i),
    .wr_byteen_i('b1),

    .rd_clk_i(rd_clk_i),

    .rd_en_i(rd_en_i & ~rd_empty_o),
    .rd_addr_i(rd_addr_r[$clog2(O_DEPTH)-1:0]),
    .rd_data_o(rd_data_o)
);

always_ff @(posedge wr_clk_i or negedge wr_rst_n_i)
begin
    if (!wr_rst_n_i) begin
        wr_addr_w <= 'b0;
    end else begin
        wr_addr_w <= (wr_en_i & ~wr_full_o) ? wr_addr_w + 1'b1 : wr_addr_w;
    end
end

always_ff @(posedge rd_clk_i or negedge rd_rst_n_i)
begin
    if (!rd_rst_n_i) begin
        rd_addr_r <= 'b0;
    end else begin
        rd_addr_r <= (rd_en_i & ~rd_empty_o) ? rd_addr_r + 1'b1 : rd_addr_r;
    end
end

endmodule
