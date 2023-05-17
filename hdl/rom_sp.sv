/*
 * rom_sp.sv
 *
 *  Created on: 2023-05-10 23:47
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module rom_sp #(
    parameter FILE = "rom_init.txt",
    parameter WIDTH = 8,
    parameter DEPTH = 8,
    parameter OUT_REG = 1
) (
    input logic rd_clk_i,

    input  logic                     rd_en_i,
    input  logic [$clog2(DEPTH)-1:0] rd_addr_i,
    output logic         [WIDTH-1:0] rd_data_o
);

logic [WIDTH-1:0] rom[DEPTH];

initial begin
    $readmemh(FILE, rom);
end

generate
    if (!OUT_REG) begin
        assign rd_data_o = rom[rd_addr_i];
    end else begin
        always_ff @(posedge rd_clk_i) begin
            if (rd_en_i) begin
                rd_data_o <= rom[rd_addr_i];
            end
        end
    end
endgenerate

endmodule
