/*
 * crc.sv
 *
 *  Created on: 2023-11-19 02:44
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import math_pkg::*;

module crc #(
    parameter     bit REFI = 0,
    parameter     bit REFO = 0,
    parameter longint POLY = 32'h04c1_1db7,
    parameter longint INIT = 32'hffff_ffff,
    parameter longint XORO = 32'h0000_0000,
    parameter     int I_WIDTH = 8,
    parameter     int O_WIDTH = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [I_WIDTH-1:0] in_data_i,
    input logic               in_valid_i,

    output logic [O_WIDTH-1:0] out_data_o,
    output logic               out_valid_o
);

logic [O_WIDTH-1:0] data_k;
logic [O_WIDTH-1:0] data_m;

logic [O_WIDTH-1:0] data_n;
logic [O_WIDTH-1:0] data_r;

logic [O_WIDTH-1:0] [O_WIDTH-1:0] poly_x;

logic [O_WIDTH-1:0] [O_WIDTH-1:0] data_x;
logic [O_WIDTH-1:0] [O_WIDTH-1:0] lfsr_x;

logic [O_WIDTH-1:0] [O_WIDTH-1:0] data_d;
logic [O_WIDTH-1:0] [O_WIDTH-1:0] lfsr_d;

generate
    genvar i, j;

    for (i = 1; i < O_WIDTH; i++) begin
        assign poly_x[i] = {poly_x[i-1][O_WIDTH-2:0], 1'b0} ^ (poly_x[0] & {O_WIDTH{poly_x[i-1][O_WIDTH-1]}});
    end

    assign poly_x[0] = POLY;

    for (i = 0; i < O_WIDTH; i++) begin
        for (j = 0; j < O_WIDTH; j++) begin
            if (j < (O_WIDTH - I_WIDTH)) begin
                assign data_x[i][O_WIDTH-1-j] = 'b0;
                assign lfsr_x[i][          j] = (j + I_WIDTH) == i;
            end else begin
                assign data_x[i][O_WIDTH-1-j] = REFI ? poly_x[j-(O_WIDTH-I_WIDTH)][i] : poly_x[O_WIDTH-1-j][i];
                assign lfsr_x[i][          j] =        poly_x[j-(O_WIDTH-I_WIDTH)][i];
            end

            assign data_d[i][j] = (j < I_WIDTH) & data_x[i][j] ? in_data_i[j] : 'b0;
            assign lfsr_d[i][j] = (j < O_WIDTH) & lfsr_x[i][j] ?    data_n[j] : 'b0;
        end

        assign data_k[i] = ^{data_d[i], lfsr_d[i]};
    end

    assign data_m = REFO ? {<< bit{data_k}} : data_k;
    assign data_r = XORO ^ data_m;
endgenerate

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        data_n <= INIT;
    end else begin
        data_n <= in_valid_i ? data_k : data_n;
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        out_data_o  <= INIT;
        out_valid_o <= 'b0;
    end else begin
        out_data_o  <= in_valid_i ? data_r : out_data_o;
        out_valid_o <= in_valid_i;
    end
end

endmodule
