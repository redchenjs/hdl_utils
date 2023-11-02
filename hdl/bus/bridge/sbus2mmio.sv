/*
 * sbus2mmio.sv
 *
 *  Created on: 2021-08-22 18:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module sbus2mmio #(
    parameter XLEN = 32,
    parameter BASE = 32'h4000_0000
) (
    input logic clk_i,
    input logic rst_n_i,

    // shared bus port
    input logic [XLEN-1:0] rd_addr_i,
    inout wire  [XLEN-1:0] rd_data_io,

    input logic [XLEN-1:0] wr_addr_i,
    input logic [XLEN-1:0] wr_data_i,

    // mmio port
    output logic            wr_en_o,
    output logic [XLEN-1:0] wr_addr_o,
    output logic [XLEN-1:0] wr_data_o,

    output logic            rd_en_o,
    output logic [XLEN-1:0] rd_addr_o,
    input  logic [XLEN-1:0] rd_data_i
);

logic [XLEN-1:0] rd_data;
logic            rd_en_r;

wire rd_en = (rd_addr_i[31:8] == BASE[31:8]);
wire wr_en = (wr_addr_i[31:8] == BASE[31:8]);

assign rd_data_io = rd_en_r ? rd_data : {XLEN{1'bz}};

assign wr_en_o   = wr_en;
assign wr_addr_o = wr_addr_i;
assign wr_data_o = wr_data_i;

assign rd_en_o   = rd_en;
assign rd_addr_o = rd_addr_i;
assign rd_data   = rd_data_i;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rd_en_r <= 'b0;
    end else begin
        rd_en_r <= rd_en;
    end
end

endmodule
