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
    parameter D_WIDTH = 32,
    parameter D_DEPTH = 64,
    parameter BYTE_EN = 0,
    parameter REG_OUT = 1
) (
    input logic rw_clk_i,

    input logic [(BYTE_EN?(D_WIDTH/8-1):0):0] wr_en_i,
    input logic                 [D_WIDTH-1:0] wr_data_i,

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
        if (BYTE_EN) begin
            for (int i = 0; i < D_WIDTH/8; i++) begin
                if (wr_en_i[i]) begin
                    ram[rw_addr_i][i*8+:8] <= wr_data_i[i*8+:8];
                end
            end
        end else begin
            if (wr_en_i) begin
                ram[rw_addr_i] <= wr_data_i;
            end
        end
    end

    if (REG_OUT) begin
        always_ff @(posedge rw_clk_i) begin
            if (rd_en_i) begin
                rd_data_o <= ram[rw_addr_i];
            end
        end
    end else begin
        assign rd_data_o = ram[rw_addr_i];
    end
endgenerate

endmodule
