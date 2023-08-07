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
    parameter D_WIDTH = 64,
    parameter D_DEPTH = 32,
    parameter REG_OUT = 1
) (
    input logic rw_clk_i,

    input logic               wr_en_i,
    input logic [D_WIDTH-1:0] wr_data_i,

    input logic [$clog2(D_DEPTH)-1:0] rw_addr_i,

    input  logic               rd_en_i,
    output logic [D_WIDTH-1:0] rd_data_o
);

generate
    logic [D_WIDTH-1:0] ram[D_DEPTH];

    if (INIT) begin
        initial begin
            $readmemh(FILE, ram);
        end
    end

    always_ff @(posedge rw_clk_i) begin
        if (wr_en_i) begin
            ram[rw_addr_i] <= wr_data_i;
        end
    end

    if (!REG_OUT) begin
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
