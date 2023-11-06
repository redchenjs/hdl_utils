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
    parameter I_WIDTH = 32,
    parameter I_DEPTH = 64,
    parameter O_WIDTH = 32,
    parameter O_DEPTH = 64,
    parameter BYTE_EN = 0,
    parameter REG_OUT = 1
) (
    input logic wr_clk_i,

    input logic                               wr_en_i,
    input logic         [$clog2(I_DEPTH)-1:0] wr_addr_i,
    input logic                 [I_WIDTH-1:0] wr_data_i,
    input logic [(BYTE_EN?(I_WIDTH/8-1):0):0] wr_byteen_i,

    input logic rd_clk_i,

    input  logic                       rd_en_i,
    input  logic [$clog2(O_DEPTH)-1:0] rd_addr_i,
    output logic         [O_WIDTH-1:0] rd_data_o
);

localparam MIN_WIDTH = (I_WIDTH < O_WIDTH) ? I_WIDTH : O_WIDTH;
localparam MAX_DEPTH = (I_DEPTH > O_DEPTH) ? I_DEPTH : O_DEPTH;

generate
    logic [MIN_WIDTH-1:0] ram[MAX_DEPTH];

    if (INIT) begin
        initial begin
            $readmemh(FILE, ram);
        end
    end

    if (BYTE_EN) begin
        if (I_WIDTH/O_WIDTH > 1) begin
            genvar k;

            for (k = 0; k < I_WIDTH/O_WIDTH; k++) begin: gen_wr_data
                always_ff @(posedge wr_clk_i) begin
                    for (int i = 0; i < O_WIDTH/8; i++) begin
                        if (wr_en_i & wr_byteen_i[i]) begin
                            ram[{wr_addr_i, k[$clog2(I_WIDTH/O_WIDTH)-1:0]}][i*8+:8] <= wr_data_i[k*O_WIDTH+i*8+:8];
                        end
                    end
                end
            end
        end else begin
            always_ff @(posedge wr_clk_i) begin
                for (int i = 0; i < I_WIDTH/8; i++) begin
                    if (wr_en_i & wr_byteen_i[i]) begin
                        ram[wr_addr_i][i*8+:8] <= wr_data_i[i*8+:8];
                    end
                end
            end
        end
    end else begin
        always_ff @(posedge wr_clk_i) begin
            if (wr_en_i) begin
                if (I_WIDTH/O_WIDTH > 1) begin
                    for (int k = 0; k < I_WIDTH/O_WIDTH; k++) begin
                        ram[{wr_addr_i, k[$clog2(I_WIDTH/O_WIDTH)-1:0]}] <= wr_data_i[k*O_WIDTH+:O_WIDTH];
                    end
                end else begin
                    ram[wr_addr_i] <= wr_data_i;
                end
            end
        end
    end

    if (REG_OUT) begin
        always_ff @(posedge rd_clk_i) begin
            if (rd_en_i) begin
                if (O_WIDTH/I_WIDTH > 1) begin
                    for (int k = 0; k < O_WIDTH/I_WIDTH; k++) begin
                        rd_data_o[k*I_WIDTH+:I_WIDTH] <= ram[{rd_addr_i, k[$clog2(O_WIDTH/I_WIDTH)-1:0]}];
                    end
                end else begin
                    rd_data_o <= ram[rd_addr_i];
                end
            end
        end
    end else begin
        if (O_WIDTH/I_WIDTH > 1) begin
            genvar k;

            for (k = 0; k < O_WIDTH/I_WIDTH; k++) begin: gen_rd_data
                assign rd_data_o[k*I_WIDTH+:I_WIDTH] = ram[{rd_addr_i, k[$clog2(O_WIDTH/I_WIDTH)-1:0]}];
            end
        end else begin
            assign rd_data_o = ram[rd_addr_i];
        end
    end
endgenerate

endmodule
