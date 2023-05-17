/*
 * sra_64b.sv
 *
 *  Created on: 2022-10-09 16:05
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module sra_64b #(
    parameter OUT_REG = 1
) (
    input logic clk_i,
    input logic rst_n_i,

    input  logic init_i,
    output logic done_o,

    input logic       arith_i,
    input logic [5:0] shift_i,

    input  logic [63:0] data_i,
    output logic [63:0] data_o
);

wire [63:0] data_0 = shift_i[0] ? {{ 1{arith_i ? data_i[63] : 1'b0}}, data_i[63: 1]} : data_i;
wire [63:0] data_1 = shift_i[1] ? {{ 2{arith_i ? data_i[63] : 1'b0}}, data_0[63: 2]} : data_0;
wire [63:0] data_2 = shift_i[2] ? {{ 4{arith_i ? data_i[63] : 1'b0}}, data_1[63: 4]} : data_1;
wire [63:0] data_3 = shift_i[3] ? {{ 8{arith_i ? data_i[63] : 1'b0}}, data_2[63: 8]} : data_2;
wire [63:0] data_4 = shift_i[4] ? {{16{arith_i ? data_i[63] : 1'b0}}, data_3[63:16]} : data_3;
wire [63:0] data_5 = shift_i[5] ? {{32{arith_i ? data_i[63] : 1'b0}}, data_4[63:32]} : data_4;

generate
    if (!OUT_REG) begin
        assign done_o = init_i;
        assign data_o = init_i ? data_5 : data_i;
    end else begin
        always_ff @(posedge clk_i or negedge rst_n_i)
        begin
            if (!rst_n_i) begin
                done_o <= 'b0;
                data_o <= 'b0;
            end else begin
                done_o <= init_i;
                data_o <= init_i ? data_5 : data_o;
            end
        end
    end
endgenerate

endmodule
