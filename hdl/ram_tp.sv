/*
 * ram_tp.sv
 *
 *  Created on: 2022-12-22 22:10
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module ram_tp #(
    parameter INIT = 0,
    parameter FILE = "ram_init.txt",
    parameter I_WIDTH = 64,
    parameter I_DEPTH = 32,
    parameter O_WIDTH = 32,
    parameter O_DEPTH = 64,
    parameter REG_OUT = 1
) (
    input logic wr_clk_i,

    input logic                       wr_en_i,
    input logic [$clog2(I_DEPTH)-1:0] wr_addr_i,
    input logic         [I_WIDTH-1:0] wr_data_i,

    input logic rd_clk_i,

    input  logic                       rd_en_i,
    input  logic [$clog2(O_DEPTH)-1:0] rd_addr_i,
    output logic         [O_WIDTH-1:0] rd_data_o
);

generate
    if (O_WIDTH >= I_WIDTH) begin
        logic [I_WIDTH-1:0] ram[I_DEPTH];

        if (INIT) begin
            initial begin
                $readmemh(FILE, ram);
            end
        end

        always_ff @(posedge wr_clk_i) begin
            if (wr_en_i) begin
                ram[wr_addr_i] <= wr_data_i;
            end
        end

        if (!REG_OUT) begin
            always_comb begin
                for (int k = 0; k < O_WIDTH/I_WIDTH; k++) begin
                    rd_data_o[k*I_WIDTH+:I_WIDTH] = $clog2(O_WIDTH/I_WIDTH) ? ram[{rd_addr_i, k[$clog2(O_WIDTH/I_WIDTH)-1:0]}] : ram[rd_addr_i];
                end
            end
        end else begin
            always_ff @(posedge rd_clk_i) begin
                for (int k = 0; k < O_WIDTH/I_WIDTH; k++) begin
                    if (rd_en_i) begin
                        rd_data_o[k*I_WIDTH+:I_WIDTH] <= $clog2(O_WIDTH/I_WIDTH) ? ram[{rd_addr_i, k[$clog2(O_WIDTH/I_WIDTH)-1:0]}] : ram[rd_addr_i];
                    end
                end
            end
        end
    end else begin
        logic [O_WIDTH-1:0] ram[O_DEPTH];

        if (INIT) begin
            initial begin
                $readmemh(FILE, ram);
            end
        end

        always_ff @(posedge wr_clk_i) begin
            for (int k = 0; k < I_WIDTH/O_WIDTH; k++) begin
                if (wr_en_i) begin
                    ram[{wr_addr_i, k[$clog2(I_WIDTH/O_WIDTH)-1:0]}] <= wr_data_i[k*O_WIDTH+:O_WIDTH];
                end
            end
        end

        if (!REG_OUT) begin
            assign rd_data_o = ram[rd_addr_i];
        end else begin
            always_ff @(posedge rd_clk_i) begin
                if (rd_en_i) begin
                    rd_data_o <= ram[rd_addr_i];
                end
            end
        end
    end
endgenerate

endmodule
