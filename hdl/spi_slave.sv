/*
 * spi_slave.sv
 *
 *  Created on: 2020-04-06 23:07
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module spi_slave(
    input logic clk_i,
    input logic rst_n_i,

    input logic [7:0] in_data_i,
    input logic       in_valid_i,

    output logic [7:0] out_data_o,
    output logic       out_valid_o,

    input  logic sclk_i,
    input  logic mosi_i,
    output logic miso_o,
    input  logic cs_n_i
);

logic sclk_p;
logic sclk_n;

logic [2:0] bit_sel;
logic       bit_mosi;

logic [7:0] byte_mosi;
logic [7:0] byte_miso;

assign     miso_o = byte_miso[7];
assign out_data_o = byte_mosi;

edge2en sclk_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i(sclk_i),

    .pos_edge_o(sclk_p),
    .neg_edge_o(sclk_n),
    .any_edge_o()
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        bit_sel  <= 'b0;

        byte_mosi <= 'b0;
        byte_miso <= 'b0;

        out_valid_o <= 'b0;
    end else begin
        bit_sel <= cs_n_i ? 'b0 : (sclk_p ? bit_sel + 'b1 : bit_sel);

        byte_mosi <= sclk_p ? {byte_mosi[6:0], mosi_i} : byte_mosi;
        byte_miso <= sclk_n ? ((bit_sel == 'b0) ? in_data_i : {byte_miso[6:0], 1'b0}) : byte_miso;

        out_valid_o <= (out_valid_o & in_valid_i) ? 'b0 : (sclk_p & (bit_sel == 3'h7));
    end
end

endmodule
