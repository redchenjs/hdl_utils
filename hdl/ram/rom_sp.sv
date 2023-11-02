/*
 * rom_sp.sv
 *
 *  Created on: 2023-05-10 23:47
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module rom_sp #(
    parameter FILE = "rom_init.txt",
    parameter D_WIDTH = 32,
    parameter D_DEPTH = 64,
    parameter REG_OUT = 1
) (
    input logic rd_clk_i,

    input  logic                       rd_en_i,
    input  logic [$clog2(D_DEPTH)-1:0] rd_addr_i,
    output logic         [D_WIDTH-1:0] rd_data_o
);

logic [D_WIDTH-1:0] rom[D_DEPTH];

initial begin
    $readmemh(FILE, rom);
end

generate
    if (REG_OUT) begin
        always_ff @(posedge rd_clk_i) begin
            if (rd_en_i) begin
                rd_data_o <= rom[rd_addr_i];
            end
        end
    end else begin
        assign rd_data_o = rom[rd_addr_i];
    end
endgenerate

endmodule
