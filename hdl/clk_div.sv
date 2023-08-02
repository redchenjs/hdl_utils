/*
 * clk_div.sv
 *
 *  Created on: 2023-08-03 02:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module clk_div #(
    parameter D_WIDTH = 8
) (
    input logic clk_i,
    input logic rst_n_i,

    input  logic [D_WIDTH-1:0] div_i,
    output logic               clk_o
);

logic clk_a;
logic clk_b;

logic [D_WIDTH-1:0] clk_div;
logic [D_WIDTH-1:0] clk_cnt;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        clk_div <= 'b0;
        clk_cnt <= 'b0;
    end else begin
        clk_div <= div_i;
        clk_cnt <= (clk_cnt == clk_div) ? 'b0 : clk_cnt + 'b1;
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        clk_a <= 'b0;
    end else begin
        clk_a <= (clk_cnt <= clk_div[D_WIDTH-1:1]);
    end
end

always_ff @(negedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        clk_b <= 'b0;
    end else begin
        clk_b <= (clk_cnt <= clk_div[D_WIDTH-1:1]);
    end
end

always_comb begin
    if (clk_div == 'b0) begin
        clk_o = clk_i;
    end else if (clk_div[0] == 'b1) begin
        clk_o = clk_a;
    end else begin
        clk_o = clk_a & clk_b;
    end
end

endmodule
