/*
 * bin2gray.sv
 *
 *  Created on: 2022-12-24 02:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module bin2gray #(
    parameter WIDTH = 8,
    parameter logic OUT_REG = 1'b1
) (
    input logic clk_i,
    input logic rst_n_i,

    input  logic init_i,
    output logic done_o,

    input  logic [WIDTH-1:0] data_i,
    output logic [WIDTH-1:0] data_o
);

wire [WIDTH-1:0] data_t = data_i ^ {1'b0, data_i[WIDTH-1:1]};

if (!OUT_REG) begin
    assign done_o = init_i;
    assign data_o = init_i ? data_t : 'b0;
end else begin
    always_ff @(posedge clk_i or negedge rst_n_i)
    begin
        if (!rst_n_i) begin
            done_o <= 'b0;
            data_o <= 'b0;
        end else begin
            done_o <= init_i;
            data_o <= init_i ? data_t : data_o;
        end
    end
end

endmodule