/*
 * ram_dp.sv
 *
 *  Created on: 2022-12-22 22:10
 *      Author: Jack Chen <redchenjs@live.com>
 */

module ram_dp #(
    parameter WIDTH = 8,
    parameter DEPTH = 8,
    parameter logic OUT_REG = 1'b1
) (
    input logic wr_clk_i,

    input logic                     wr_a_en_i,
    input logic [$clog2(DEPTH)-1:0] wr_a_addr_i,
    input logic [WIDTH/8-1:0] [7:0] wr_a_data_i,
    input logic       [WIDTH/8-1:0] wr_a_byte_en_i,

    input logic                     wr_b_en_i,
    input logic [$clog2(DEPTH)-1:0] wr_b_addr_i,
    input logic [WIDTH/8-1:0] [7:0] wr_b_data_i,
    input logic       [WIDTH/8-1:0] wr_b_byte_en_i,

    input  logic                     rd_a_en_i,
    input  logic                     rd_a_clk_i,
    input  logic [$clog2(DEPTH)-1:0] rd_a_addr_i,
    output logic         [WIDTH-1:0] rd_a_data_o,

    input  logic                     rd_b_en_i,
    input  logic                     rd_b_clk_i,
    input  logic [$clog2(DEPTH)-1:0] rd_b_addr_i,
    output logic         [WIDTH-1:0] rd_b_data_o
);

logic [WIDTH/8-1:0] [7:0] ram[DEPTH];

always @(posedge wr_clk_i) begin
    if (wr_a_en_i) begin
        for (int i = 0; i < WIDTH/8; i++) begin
            if (wr_a_byte_en_i[i]) begin
                ram[wr_a_addr_i][i] <= wr_a_data_i[i];
            end
        end
    end

    if (wr_b_en_i) begin
        for (int i = 0; i < WIDTH/8; i++) begin
            if (wr_b_byte_en_i[i]) begin
                ram[wr_b_addr_i][i] <= wr_b_data_i[i];
            end
        end
    end
end

if (!OUT_REG) begin
    assign rd_a_data_o = ram[rd_a_addr_i];
    assign rd_b_data_o = ram[rd_b_addr_i];
end else begin
    always @(posedge rd_a_clk_i) begin
        if (rd_a_en_i) begin
            rd_a_data_o <= ram[rd_a_addr_i];
        end
    end

    always @(posedge rd_b_clk_i) begin
        if (rd_b_en_i) begin
            rd_b_data_o <= ram[rd_b_addr_i];
        end
    end
end

endmodule
