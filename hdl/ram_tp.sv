/*
 * ram_tp.sv
 *
 *  Created on: 2022-12-22 22:10
 *      Author: Jack Chen <redchenjs@live.com>
 */

module ram_tp #(
    parameter WIDTH = 8,
    parameter DEPTH = 8,
    parameter logic OUT_REG = 1'b1
) (
    input logic wr_clk_i,

    input logic                     wr_en_i,
    input logic [$clog2(DEPTH)-1:0] wr_addr_i,
    input logic [WIDTH/8-1:0] [7:0] wr_data_i,
    input logic       [WIDTH/8-1:0] wr_byte_en_i,

    input logic rd_clk_i,

    input  logic                     rd_en_i,
    input  logic [$clog2(DEPTH)-1:0] rd_addr_i,
    output logic         [WIDTH-1:0] rd_data_o
);

logic [WIDTH/8-1:0] [7:0] ram[DEPTH];

always @(posedge wr_clk_i) begin
    if (wr_en_i) begin
        for (int i = 0; i < WIDTH/8; i++) begin
            if (wr_byte_en_i[i]) begin
                ram[wr_addr_i][i] <= wr_data_i[i];
            end
        end
    end
end

if (!OUT_REG) begin
    assign rd_data_o = ram[rd_addr_i];
end else begin
    always @(posedge rd_clk_i) begin
        if (rd_en_i) begin
            rd_data_o <= ram[rd_addr_i];
        end
    end
end

endmodule
