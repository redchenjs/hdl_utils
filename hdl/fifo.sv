/*
 * fifo.sv
 *
 *  Created on: 2022-12-22 23:34
 *      Author: Jack Chen <redchenjs@live.com>
 */

module fifo #(
    parameter I_WIDTH = 8,
    parameter I_DEPTH = 8,
    parameter O_WIDTH = 8,
    parameter O_DEPTH = 8
) (
    input logic clk_i,
    input logic rst_n_i,

    input  logic                     wr_en_i,
    input  logic       [I_WIDTH-1:0] wr_data_i,
    output logic                     wr_full_o,
    output logic [$clog2(I_DEPTH):0] wr_free_o,

    input  logic                     rd_en_i,
    output logic       [O_WIDTH-1:0] rd_data_o,
    output logic                     rd_empty_o,
    output logic [$clog2(O_DEPTH):0] rd_avail_o
);

logic [$clog2(I_DEPTH):0] wr_addr;
logic [$clog2(O_DEPTH):0] rd_addr;

if (O_WIDTH >= I_WIDTH) begin
    wire [$clog2(I_DEPTH):0] rd_addr_ext  = {rd_addr, {$clog2(I_DEPTH/O_DEPTH){1'b0}}};
    wire [$clog2(I_DEPTH):0] rd_avail_ext = {wr_addr[$clog2(I_DEPTH)] ^ rd_addr_ext[$clog2(I_DEPTH)], wr_addr[$clog2(I_DEPTH)-1:0]} - {1'b0, rd_addr_ext[$clog2(I_DEPTH)-1:0]};

    assign wr_full_o = (rd_addr_ext == {~wr_addr[$clog2(I_DEPTH)], wr_addr[$clog2(I_DEPTH)-1:0]});
    assign wr_free_o = (I_DEPTH - ({wr_addr[$clog2(I_DEPTH)] ^ rd_addr_ext[$clog2(I_DEPTH)], wr_addr[$clog2(I_DEPTH)-1:0]} - {1'b0, rd_addr_ext[$clog2(I_DEPTH)-1:0]}));

    assign rd_empty_o = (rd_addr_ext == wr_addr);
    assign rd_avail_o = ({{$clog2(I_DEPTH/O_DEPTH){1'b0}}, rd_avail_ext[$clog2(I_DEPTH):$clog2(I_DEPTH/O_DEPTH)]});
end else begin
    wire [$clog2(O_DEPTH):0] wr_addr_ext = {wr_addr, {$clog2(O_DEPTH/I_DEPTH){1'b0}}};
    wire [$clog2(O_DEPTH):0] wr_free_ext = (O_DEPTH - ({wr_addr_ext[$clog2(O_DEPTH)] ^ rd_addr[$clog2(O_DEPTH)], wr_addr_ext[$clog2(O_DEPTH)-1:0]} - {1'b0, rd_addr[$clog2(O_DEPTH)-1:0]}));

    assign wr_full_o = (rd_addr == {~wr_addr_ext[$clog2(O_DEPTH)], wr_addr_ext[$clog2(O_DEPTH)-1:0]});
    assign wr_free_o = ({{$clog2(O_DEPTH/I_DEPTH){1'b0}}, wr_free_ext[$clog2(O_DEPTH):$clog2(O_DEPTH/I_DEPTH)]});

    assign rd_empty_o = (rd_addr == wr_addr_ext);
    assign rd_avail_o = ({wr_addr_ext[$clog2(O_DEPTH)] ^ rd_addr[$clog2(O_DEPTH)], wr_addr_ext[$clog2(O_DEPTH)-1:0]} - {1'b0, rd_addr[$clog2(O_DEPTH)-1:0]});
end

ram_tp #(
    .I_WIDTH(I_WIDTH),
    .I_DEPTH(I_DEPTH),
    .O_WIDTH(O_WIDTH),
    .O_DEPTH(O_DEPTH),
    .OUT_REG(1'b1)
) ram_tp (
    .wr_clk_i(clk_i),

    .wr_en_i(wr_en_i & ~wr_full_o),
    .wr_addr_i(wr_addr[$clog2(I_DEPTH)-1:0]),
    .wr_data_i(wr_data_i),
    .wr_byte_en_i({(I_WIDTH/8){1'b1}}),

    .rd_clk_i(clk_i),

    .rd_en_i(rd_en_i & ~rd_empty_o),
    .rd_addr_i(rd_addr[$clog2(O_DEPTH)-1:0]),
    .rd_data_o(rd_data_o)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        wr_addr <= 'b0;
        rd_addr <= 'b0;
    end else begin
        wr_addr <= (wr_en_i & ~wr_full_o)  ? wr_addr + 1'b1 : wr_addr;
        rd_addr <= (rd_en_i & ~rd_empty_o) ? rd_addr + 1'b1 : rd_addr;
    end
end

endmodule
