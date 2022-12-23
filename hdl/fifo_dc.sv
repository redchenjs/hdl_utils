/*
 * fifo_dc.sv
 *
 *  Created on: 2022-12-22 23:34
 *      Author: Jack Chen <redchenjs@live.com>
 */

module fifo_dc #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
) (
    input logic wr_clk_i,
    input logic wr_rst_n_i,

    input  logic                   wr_en_i,
    input  logic       [WIDTH-1:0] wr_data_i,
    output logic                   wr_last_o,
    output logic                   wr_full_o,
    output logic [$clog2(DEPTH):0] wr_free_o,

    input logic rd_clk_i,
    input logic rd_rst_n_i,

    input  logic                   rd_en_i,
    output logic       [WIDTH-1:0] rd_data_o,
    output logic                   rd_last_o,
    output logic                   rd_empty_o,
    output logic [$clog2(DEPTH):0] rd_avail_o
);

logic [$clog2(DEPTH):0] wr_addr_w;
logic [$clog2(DEPTH):0] wr_addr_g;
logic [$clog2(DEPTH):0] wr_addr_s;
logic [$clog2(DEPTH):0] wr_addr_r;

logic [$clog2(DEPTH):0] rd_addr_w;
logic [$clog2(DEPTH):0] rd_addr_g;
logic [$clog2(DEPTH):0] rd_addr_s;
logic [$clog2(DEPTH):0] rd_addr_r;

wire [$clog2(DEPTH):0] wr_addr_w_next = wr_addr_w + 1'b1;
wire [$clog2(DEPTH):0] wr_addr_r_next = wr_addr_r + 1'b1;
wire [$clog2(DEPTH):0] rd_addr_w_next = rd_addr_w + 1'b1;
wire [$clog2(DEPTH):0] rd_addr_r_next = rd_addr_r + 1'b1;

assign wr_last_o = (rd_addr_w == {~wr_addr_w_next[$clog2(DEPTH)], wr_addr_w_next[$clog2(DEPTH)-1:0]});
assign wr_full_o = (rd_addr_w == {~wr_addr_w[$clog2(DEPTH)], wr_addr_w[$clog2(DEPTH)-1:0]});
assign wr_free_o = (DEPTH - ({wr_addr_w[$clog2(DEPTH)] ^ rd_addr_w[$clog2(DEPTH)], wr_addr_w[$clog2(DEPTH)-1:0]} - {1'b0, rd_addr_w[$clog2(DEPTH)-1:0]}));

assign rd_last_o  = (wr_addr_r == rd_addr_r_next);
assign rd_empty_o = (wr_addr_r == rd_addr_r);
assign rd_avail_o = ({wr_addr_r[$clog2(DEPTH)] ^ rd_addr_r[$clog2(DEPTH)], wr_addr_r[$clog2(DEPTH)-1:0]} - {1'b0, rd_addr_r[$clog2(DEPTH)-1:0]});

bin2gray #(
    .WIDTH($clog2(DEPTH)+1),
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
    .WIDTH($clog2(DEPTH)+1)
) wr_addr_w2r (
    .clk_i(rd_clk_i),
    .rst_n_i(rd_rst_n_i),

    .data_i(wr_addr_g),
    .data_o(wr_addr_s)
);

gray2bin #(
    .WIDTH($clog2(DEPTH)+1),
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
    .WIDTH($clog2(DEPTH)+1),
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
    .WIDTH($clog2(DEPTH)+1)
) rd_addr_r2w (
    .clk_i(wr_clk_i),
    .rst_n_i(wr_rst_n_i),

    .data_i(rd_addr_g),
    .data_o(rd_addr_s)
);

gray2bin #(
    .WIDTH($clog2(DEPTH)+1),
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
    .WIDTH(WIDTH),
    .DEPTH(DEPTH),
    .OUT_REG(1'b1)
) ram_tp (
    .wr_clk_i(wr_clk_i),

    .wr_en_i(wr_en_i & ~wr_full_o),
    .wr_addr_i(wr_addr_w[$clog2(DEPTH)-1:0]),
    .wr_data_i(wr_data_i),
    .wr_byte_en_i({WIDTH/8{1'b1}}),

    .rd_clk_i(rd_clk_i),

    .rd_en_i(rd_en_i & ~rd_empty_o),
    .rd_addr_i(rd_addr_r[$clog2(DEPTH)-1:0]),
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