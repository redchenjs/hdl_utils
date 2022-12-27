/*
 * ram_sp.sv
 *
 *  Created on: 2022-12-22 22:10
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module ram_sp #(
    parameter WIDTH = 8,
    parameter DEPTH = 8,
    parameter logic OUT_REG = 1'b1
) (
    input logic wr_clk_i,

    input logic               wr_en_i,
    input logic [WIDTH/8-1:0] wr_byte_en_i,

    input logic [$clog2(DEPTH)-1:0] rw_addr_i,
    input logic         [WIDTH-1:0] rw_data_i,

    input logic rd_clk_i,

    input  logic             rd_en_i,
    output logic [WIDTH-1:0] rd_data_o
);

logic [WIDTH-1:0] ram[DEPTH];

generate
    genvar i;
    for (i = 0; i < WIDTH/8; i++) begin: gen_wr_be
        always_ff @(posedge wr_clk_i) begin
            if (wr_en_i & wr_byte_en_i[i]) begin
                ram[rw_addr_i][i*8+7:i*8] <= rw_data_i[i*8+7:i*8];
            end
        end
    end

    if (!OUT_REG) begin
        assign rd_data_o = ram[rw_addr_i];
    end else begin
        always_ff @(posedge rd_clk_i) begin
            if (rd_en_i) begin
                rd_data_o <= ram[rw_addr_i];
            end
        end
    end
endgenerate

endmodule
