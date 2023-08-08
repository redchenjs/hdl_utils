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
    parameter D_WIDTH = 32,
    parameter D_DEPTH = 64,
    parameter BYTE_EN = 0,
    parameter REG_OUT = 1
) (
    input logic wr_clk_a_i,

    input logic [(BYTE_EN?(D_WIDTH/8-1):0):0] wr_en_a_i,
    input logic         [$clog2(D_DEPTH)-1:0] wr_addr_a_i,
    input logic                 [D_WIDTH-1:0] wr_data_a_i,

    input logic rd_clk_a_i,

    input  logic                       rd_en_a_i,
    input  logic [$clog2(D_DEPTH)-1:0] rd_addr_a_i,
    output logic         [D_WIDTH-1:0] rd_data_a_o,

    input logic wr_clk_b_i,

    input logic [(BYTE_EN?(D_WIDTH/8-1):0):0] wr_en_b_i,
    input logic         [$clog2(D_DEPTH)-1:0] wr_addr_b_i,
    input logic                 [D_WIDTH-1:0] wr_data_b_i,

    input logic rd_clk_b_i,

    input  logic                       rd_en_b_i,
    input  logic [$clog2(D_DEPTH)-1:0] rd_addr_b_i,
    output logic         [D_WIDTH-1:0] rd_data_b_o
);

generate
    logic [D_WIDTH-1:0] ram[D_DEPTH];

    if (INIT) begin
        initial begin
            $readmemh(FILE, ram);
        end
    end

    always_ff @(posedge wr_clk_a_i) begin
        if (BYTE_EN) begin
            for (int i = 0; i < D_WIDTH/8; i++) begin
                if (wr_en_a_i[i]) begin
                    ram[wr_addr_a_i][i*8+:8] <= wr_data_a_i[i*8+:8];
                end
            end
        end else begin
            if (wr_en_a_i) begin
                ram[wr_addr_a_i] <= wr_data_a_i;
            end
        end
    end

    always_ff @(posedge wr_clk_b_i) begin
        if (BYTE_EN) begin
            for (int i = 0; i < D_WIDTH/8; i++) begin
                if (wr_en_b_i[i]) begin
                    ram[wr_addr_b_i][i*8+:8] <= wr_data_b_i[i*8+:8];
                end
            end
        end else begin
            if (wr_en_b_i) begin
                ram[wr_addr_b_i] <= wr_data_b_i;
            end
        end
    end

    if (REG_OUT) begin
        always_ff @(posedge rd_clk_a_i) begin
            if (rd_en_a_i) begin
                rd_data_a_o <= ram[rd_addr_a_i];
            end
        end

        always_ff @(posedge rd_clk_b_i) begin
            if (rd_en_b_i) begin
                rd_data_b_o <= ram[rd_addr_b_i];
            end
        end
    end else begin
        assign rd_data_a_o = ram[rd_addr_a_i];
        assign rd_data_b_o = ram[rd_addr_b_i];
    end
endgenerate

endmodule
