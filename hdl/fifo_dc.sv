/*
 * fifo_dc.sv
 *
 *  Created on: 2022-12-22 23:34
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module fifo_dc #(
    parameter I_WIDTH = 32,
    parameter I_DEPTH = 64,
    parameter O_WIDTH = 32,
    parameter O_DEPTH = 64
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

logic [$clog2(I_DEPTH):0] wr_addr_w;
logic [$clog2(I_DEPTH):0] wr_addr_g;
logic [$clog2(I_DEPTH):0] wr_addr_s;
logic [$clog2(I_DEPTH):0] wr_addr_r;

logic [$clog2(O_DEPTH):0] rd_addr_w;
logic [$clog2(O_DEPTH):0] rd_addr_g;
logic [$clog2(O_DEPTH):0] rd_addr_s;
logic [$clog2(O_DEPTH):0] rd_addr_r;

generate
    if (O_WIDTH >= I_WIDTH) begin
        wire [$clog2(I_DEPTH):0] rd_addr_w_ext  = {rd_addr_w, {$clog2(I_DEPTH/O_DEPTH){1'b0}}};
        wire [$clog2(I_DEPTH):0] rd_addr_r_ext  = {rd_addr_r, {$clog2(I_DEPTH/O_DEPTH){1'b0}}};
        wire [$clog2(I_DEPTH):0] rd_avail_w_ext = {wr_addr_w[$clog2(I_DEPTH)] ^ rd_addr_w_ext[$clog2(I_DEPTH)], wr_addr_w[$clog2(I_DEPTH)-1:0]} - {1'b0, rd_addr_w_ext[$clog2(I_DEPTH)-1:0]};
        wire [$clog2(I_DEPTH):0] rd_avail_r_ext = {wr_addr_r[$clog2(I_DEPTH)] ^ rd_addr_r_ext[$clog2(I_DEPTH)], wr_addr_r[$clog2(I_DEPTH)-1:0]} - {1'b0, rd_addr_r_ext[$clog2(I_DEPTH)-1:0]};

        assign wr_full_o = (rd_addr_w_ext == {~wr_addr_w[$clog2(I_DEPTH)], wr_addr_w[$clog2(I_DEPTH)-1:0]});
        assign wr_free_o = (I_DEPTH - ({wr_addr_w[$clog2(I_DEPTH)] ^ rd_addr_w_ext[$clog2(I_DEPTH)], wr_addr_w[$clog2(I_DEPTH)-1:0]} - {1'b0, rd_addr_w_ext[$clog2(I_DEPTH)-1:0]}));

        assign rd_empty_o = (rd_addr_r_ext == wr_addr_r);
        assign rd_avail_o = ({{$clog2(I_DEPTH/O_DEPTH){1'b0}}, rd_avail_r_ext[$clog2(I_DEPTH):$clog2(I_DEPTH/O_DEPTH)]});
    end else begin
        wire [$clog2(O_DEPTH):0] wr_addr_w_ext = {wr_addr_w, {$clog2(O_DEPTH/I_DEPTH){1'b0}}};
        wire [$clog2(O_DEPTH):0] wr_addr_r_ext = {wr_addr_r, {$clog2(O_DEPTH/I_DEPTH){1'b0}}};
        wire [$clog2(O_DEPTH):0] wr_free_w_ext = (O_DEPTH - ({wr_addr_w_ext[$clog2(O_DEPTH)] ^ rd_addr_w[$clog2(O_DEPTH)], wr_addr_w_ext[$clog2(O_DEPTH)-1:0]} - {1'b0, rd_addr_w[$clog2(O_DEPTH)-1:0]}));
        wire [$clog2(O_DEPTH):0] wr_free_r_ext = (O_DEPTH - ({wr_addr_r_ext[$clog2(O_DEPTH)] ^ rd_addr_r[$clog2(O_DEPTH)], wr_addr_r_ext[$clog2(O_DEPTH)-1:0]} - {1'b0, rd_addr_r[$clog2(O_DEPTH)-1:0]}));

        assign wr_full_o = (rd_addr_w == {~wr_addr_w_ext[$clog2(O_DEPTH)], wr_addr_w_ext[$clog2(O_DEPTH)-1:0]});
        assign wr_free_o = ({{$clog2(O_DEPTH/I_DEPTH){1'b0}}, wr_free_w_ext[$clog2(O_DEPTH):$clog2(O_DEPTH/I_DEPTH)]});

        assign rd_empty_o = (rd_addr_r == wr_addr_r_ext);
        assign rd_avail_o = ({wr_addr_r_ext[$clog2(O_DEPTH)] ^ rd_addr_r[$clog2(O_DEPTH)], wr_addr_r_ext[$clog2(O_DEPTH)-1:0]} - {1'b0, rd_addr_r[$clog2(O_DEPTH)-1:0]});
    end
endgenerate

bin2gray #(
    .WIDTH($clog2(I_DEPTH)+1),
    .OUT_REG(1'b0)
) bin2gray_w2r (
    .clk_i(wr_clk_i),
    .rst_n_i(wr_rst_n_i),

    .init_i(1'b1),
    .done_o(),

    .data_i(wr_addr_w),
    .data_o(wr_addr_g)
);

data_sync #(
    .WIDTH($clog2(I_DEPTH)+1)
) data_sync_w2r (
    .clk_i(rd_clk_i),
    .rst_n_i(rd_rst_n_i),

    .data_i(wr_addr_g),
    .data_o(wr_addr_s)
);

gray2bin #(
    .WIDTH($clog2(I_DEPTH)+1),
    .OUT_REG(1'b0)
) gray2bin_w2r (
    .clk_i(rd_clk_i),
    .rst_n_i(rd_rst_n_i),

    .init_i(1'b1),
    .done_o(),

    .data_i(wr_addr_s),
    .data_o(wr_addr_r)
);

bin2gray #(
    .WIDTH($clog2(O_DEPTH)+1),
    .OUT_REG(1'b0)
) bin2gray_r2w (
    .clk_i(rd_clk_i),
    .rst_n_i(rd_rst_n_i),

    .init_i(1'b1),
    .done_o(),

    .data_i(rd_addr_r),
    .data_o(rd_addr_g)
);

data_sync #(
    .WIDTH($clog2(O_DEPTH)+1)
) data_sync_r2w (
    .clk_i(wr_clk_i),
    .rst_n_i(wr_rst_n_i),

    .data_i(rd_addr_g),
    .data_o(rd_addr_s)
);

gray2bin #(
    .WIDTH($clog2(O_DEPTH)+1),
    .OUT_REG(1'b0)
) gray2bin_r2w (
    .clk_i(wr_clk_i),
    .rst_n_i(wr_rst_n_i),

    .init_i(1'b1),
    .done_o(),

    .data_i(rd_addr_s),
    .data_o(rd_addr_w)
);

ram_tp #(
    .I_WIDTH(I_WIDTH),
    .I_DEPTH(I_DEPTH),
    .O_WIDTH(O_WIDTH),
    .O_DEPTH(O_DEPTH),
    .OUT_REG(1'b1)
) ram_tp (
    .wr_clk_i(wr_clk_i),

    .wr_en_i(wr_en_i & ~wr_full_o),
    .wr_addr_i(wr_addr_w[$clog2(I_DEPTH)-1:0]),
    .wr_data_i(wr_data_i),
    .wr_byte_en_i({(I_WIDTH/8){1'b1}}),

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
