/*
 * data_hs.sv
 *
 *  Created on: 2021-07-12 15:07
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module data_hs #(
    parameter WIDTH = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input  logic [WIDTH-1:0] in_data_i,
    input  logic             in_valid_i,
    output logic             in_ready_o,

    output logic [WIDTH-1:0] out_data_o,
    output logic             out_valid_o,
    input  logic             out_ready_i
);

logic [WIDTH-1:0] out_data;
logic             out_valid;

assign in_ready_o  = out_ready_i | ~out_valid;
assign out_data_o  = out_data;
assign out_valid_o = out_valid;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        out_data  <= 'b0;
        out_valid <= 'b0;
    end else begin
        if (in_ready_o) begin
            out_data  <= in_data_i;
            out_valid <= in_valid_i;
        end
    end
end

endmodule
