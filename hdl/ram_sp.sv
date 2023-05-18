/*
 * ram_sp.sv
 *
 *  Created on: 2022-12-22 22:10
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module ram_sp #(
    parameter INIT = 0,
    parameter FILE = "ram_init.txt",
    parameter WIDTH = 8,
    parameter DEPTH = 8,
    parameter OUT_REG = 1
) (
    input logic rw_clk_i,

    input logic               wr_en_i,
    input logic   [WIDTH-1:0] wr_data_i,
    input logic [WIDTH/8-1:0] wr_byte_en_i,

    input logic [$clog2(DEPTH)-1:0] rw_addr_i,

    input  logic                     rd_en_i,
    output logic         [WIDTH-1:0] rd_data_o
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
        always_ff @(posedge rw_clk_i) begin
            if (wr_en_i & wr_byte_en_i[i]) begin
                ram[rw_addr_i][i*8+7:i*8] <= wr_data_i[i*8+7:i*8];
            end
        end
    end

    if (!OUT_REG) begin
        assign rd_data_o = ram[rw_addr_i];
    end else begin
        always_ff @(posedge rw_clk_i) begin
            if (rd_en_i) begin
                rd_data_o <= ram[rw_addr_i];
            end
        end
    end
endgenerate

endmodule
