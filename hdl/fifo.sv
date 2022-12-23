/*
 * fifo.sv
 *
 *  Created on: 2022-12-22 23:34
 *      Author: Jack Chen <redchenjs@live.com>
 */

module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
) (
    input logic clk_i,
    input logic rst_n_i,

    input  logic                   wr_en_i,
    input  logic       [WIDTH-1:0] wr_data_i,
    output logic                   wr_last_o,
    output logic                   wr_full_o,
    output logic [$clog2(DEPTH):0] wr_free_o,

    input  logic                   rd_en_i,
    output logic       [WIDTH-1:0] rd_data_o,
    output logic                   rd_last_o,
    output logic                   rd_empty_o,
    output logic [$clog2(DEPTH):0] rd_avail_o
);

logic [$clog2(DEPTH):0] wr_addr;
logic [$clog2(DEPTH):0] rd_addr;

wire [$clog2(DEPTH):0] wr_addr_next = wr_addr + 1'b1;
wire [$clog2(DEPTH):0] rd_addr_next = rd_addr + 1'b1;

assign wr_last_o = (rd_addr == {~wr_addr_next[$clog2(DEPTH)], wr_addr_next[$clog2(DEPTH)-1:0]});
assign wr_full_o = (rd_addr == {~wr_addr[$clog2(DEPTH)], wr_addr[$clog2(DEPTH)-1:0]});
assign wr_free_o = (DEPTH - ({wr_addr[$clog2(DEPTH)] ^ rd_addr[$clog2(DEPTH)], wr_addr[$clog2(DEPTH)-1:0]} - {1'b0, rd_addr[$clog2(DEPTH)-1:0]}));

assign rd_last_o  = (wr_addr == rd_addr_next);
assign rd_empty_o = (wr_addr == rd_addr);
assign rd_avail_o = ({wr_addr[$clog2(DEPTH)] ^ rd_addr[$clog2(DEPTH)], wr_addr[$clog2(DEPTH)-1:0]} - {1'b0, rd_addr[$clog2(DEPTH)-1:0]});

ram_tp #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH),
    .OUT_REG(1'b1)
) ram_tp (
    .wr_clk_i(clk_i),

    .wr_en_i(wr_en_i & ~wr_full_o),
    .wr_addr_i(wr_addr[$clog2(DEPTH)-1:0]),
    .wr_data_i(wr_data_i),
    .wr_byte_en_i({WIDTH/8{1'b1}}),

    .rd_clk_i(clk_i),

    .rd_en_i(rd_en_i & ~rd_empty_o),
    .rd_addr_i(rd_addr[$clog2(DEPTH)-1:0]),
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
