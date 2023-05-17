/*
 * ram_dp.sv
 *
 *  Created on: 2022-12-22 22:10
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module ram_dp #(
    parameter INIT = 0,
    parameter FILE = "ram_init.txt",
    parameter WIDTH = 8,
    parameter DEPTH = 8,
    parameter OUT_REG = 1
) (
    input logic wr_clk_i,

    input logic                     wr_a_en_i,
    input logic [$clog2(DEPTH)-1:0] wr_a_addr_i,
    input logic         [WIDTH-1:0] wr_a_data_i,
    input logic       [WIDTH/8-1:0] wr_a_byte_en_i,

    input logic                     wr_b_en_i,
    input logic [$clog2(DEPTH)-1:0] wr_b_addr_i,
    input logic         [WIDTH-1:0] wr_b_data_i,
    input logic       [WIDTH/8-1:0] wr_b_byte_en_i,

    input logic rd_a_clk_i,

    input  logic                     rd_a_en_i,
    input  logic [$clog2(DEPTH)-1:0] rd_a_addr_i,
    output logic         [WIDTH-1:0] rd_a_data_o,

    input logic rd_b_clk_i,

    input  logic                     rd_b_en_i,
    input  logic [$clog2(DEPTH)-1:0] rd_b_addr_i,
    output logic         [WIDTH-1:0] rd_b_data_o
);

generate
    logic [WIDTH-1:0] ram[DEPTH];

    if (INIT) begin
        initial begin
            $readmemh(FILE, ram);
        end
    end

    genvar i;
    for (i = 0; i < WIDTH/8; i++) begin: gen_wr_be
        always_ff @(posedge wr_clk_i) begin
            if (wr_a_en_i & wr_a_byte_en_i[i]) begin
                ram[wr_a_addr_i][i*8+7:i*8] <= wr_a_data_i[i*8+7:i*8];
            end

            if (wr_b_en_i & wr_b_byte_en_i[i]) begin
                ram[wr_b_addr_i][i*8+7:i*8] <= wr_b_data_i[i*8+7:i*8];
            end
        end
    end

    if (!OUT_REG) begin
        assign rd_a_data_o = ram[rd_a_addr_i];
        assign rd_b_data_o = ram[rd_b_addr_i];
    end else begin
        always_ff @(posedge rd_a_clk_i) begin
            if (rd_a_en_i) begin
                rd_a_data_o <= ram[rd_a_addr_i];
            end
        end

        always_ff @(posedge rd_b_clk_i) begin
            if (rd_b_en_i) begin
                rd_b_data_o <= ram[rd_b_addr_i];
            end
        end
    end
endgenerate

endmodule
