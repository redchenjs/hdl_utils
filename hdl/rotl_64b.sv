/*
 * rotl_64b.sv
 *
 *  Created on: 2023-07-22 17:52
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module rotl_64b #(
    parameter D_WIDTH = 64,
    parameter REG_OUT = 1
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [D_WIDTH-1:0] in_data_i,
    input logic               in_valid_i,

    output logic [D_WIDTH-1:0] out_data_o,
    output logic               out_valid_o,

    input logic [$clog2(D_WIDTH)-1:0] shift_i
);

logic [$clog2(D_WIDTH)-1:0] [D_WIDTH-1:0] data_t;

generate
    assign data_t[0] = shift_i[0] ? {in_data_i[D_WIDTH-2:0], in_data_i[D_WIDTH-1]} : in_data_i;

    genvar i;
    for (i = 1; i < $clog2(D_WIDTH); i++) begin
        assign data_t[i] = shift_i[i] ? {data_t[i-1][D_WIDTH-1-(1<<i):0], data_t[i-1][D_WIDTH-1:D_WIDTH-(1<<i)]} : data_t[i-1];
    end

    if (!REG_OUT) begin
        assign out_data_o  = in_valid_i ? data_t[$clog2(D_WIDTH)-1] : in_data_i;
        assign out_valid_o = in_valid_i;
    end else begin
        always_ff @(posedge clk_i or negedge rst_n_i)
        begin
            if (!rst_n_i) begin
                out_data_o  <= 'b0;
                out_valid_o <= 'b0;
            end else begin
                out_data_o  <= in_valid_i ? data_t[$clog2(D_WIDTH)-1] : out_data_o;
                out_valid_o <= in_valid_i;
            end
        end
    end
endgenerate

endmodule
