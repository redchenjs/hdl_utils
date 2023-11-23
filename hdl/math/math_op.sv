/*
 * math_op.sv
 *
 *  Created on: 2023-11-19 13:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import math_pkg::*;

module math_op #(
    parameter int MATH_OP = MATH_OP_ADD,
    parameter int I_COUNT = 2,
    parameter int I_WIDTH = 64,
    parameter int O_COUNT = 1,
    parameter int O_WIDTH = 64,
    parameter bit REG_OUT = 1
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [I_COUNT-1:0] [I_WIDTH-1:0] in_data_i,
    input logic                             in_valid_i,

    output logic [O_COUNT-1:0] [O_WIDTH-1:0] out_data_o,
    output logic                             out_valid_o
);

logic [$clog2(I_WIDTH):0]               [I_WIDTH-1:0] data_s;
logic [$clog2(I_COUNT):0] [I_COUNT-1:0] [I_WIDTH-1:0] data_t;
logic [$clog2(I_COUNT):0] [I_COUNT-1:0] [O_WIDTH-1:0] data_c;
logic                     [O_COUNT-1:0] [O_WIDTH-1:0] data_r;

generate
    genvar i, j;

    case (MATH_OP)
        MATH_OP_LSL,
        MATH_OP_ROL,
        MATH_OP_LSR,
        MATH_OP_ASR,
        MATH_OP_ROR: begin
            assign data_s[0] = in_data_i;
            assign data_r[0] = data_s[$clog2(I_WIDTH)];
        end
        default: begin
            assign data_t[0] = in_data_i;
            assign data_r[0] = data_c[$clog2(I_COUNT)][0];
        end
    endcase

    for (j = 0; j < I_COUNT; j++) begin
        assign data_c[0][j] = data_t[0][j];
    end

    for (i = 0; i < $clog2(I_COUNT); i++) begin: gen_data_c
        for (j = 0; j < 2**($clog2(I_COUNT)-i)/2; j++) begin: gen_data_d
            case (MATH_OP)
                MATH_OP_ADD:  assign data_c[i+1][j] = data_c[i][j*2] +  data_c[i][j*2+1];
                MATH_OP_AND:  assign data_c[i+1][j] = data_c[i][j*2] &  data_c[i][j*2+1];
                MATH_OP_NAND: assign data_c[i+1][j] = data_c[i][j*2] &~ data_c[i][j*2+1];
                MATH_OP_OR:   assign data_c[i+1][j] = data_c[i][j*2] |  data_c[i][j*2+1];
                MATH_OP_NOR:  assign data_c[i+1][j] = data_c[i][j*2] |~ data_c[i][j*2+1];
                MATH_OP_XOR:  assign data_c[i+1][j] = data_c[i][j*2] ^  data_c[i][j*2+1];
                MATH_OP_XNOR: assign data_c[i+1][j] = data_c[i][j*2] ^~ data_c[i][j*2+1];
            endcase
        end
    end

    for (i = 0; i < $clog2(I_WIDTH); i++) begin: gen_data_s
        case (MATH_OP)
            MATH_OP_LSL: assign data_s[i+1] = in_data_i[1][i] ? { data_s[i][I_WIDTH-(1<<i)-1:0], {(1<<i){                     1'b0}}} : data_s[i];
            MATH_OP_ROL: assign data_s[i+1] = in_data_i[1][i] ? { data_s[i][I_WIDTH-(1<<i)-1:0], data_s[i][I_WIDTH-1:I_WIDTH-(1<<i)]} : data_s[i];
            MATH_OP_LSR: assign data_s[i+1] = in_data_i[1][i] ? {{(1<<i){                1'b0}}, data_s[i][I_WIDTH-1:        (1<<i)]} : data_s[i];
            MATH_OP_ASR: assign data_s[i+1] = in_data_i[1][i] ? {{(1<<i){data_s[i][I_WIDTH-1]}}, data_s[i][I_WIDTH-1:        (1<<i)]} : data_s[i];
            MATH_OP_ROR: assign data_s[i+1] = in_data_i[1][i] ? { data_s[i][        (1<<i)-1:0], data_s[i][I_WIDTH-1:        (1<<i)]} : data_s[i];
        endcase
    end

    if (REG_OUT) begin
        always_ff @(posedge clk_i or negedge rst_n_i)
        begin
            if (!rst_n_i) begin
                out_data_o  <= 'b0;
                out_valid_o <= 'b0;
            end else begin
                out_data_o  <= in_valid_i ? data_r : out_data_o;
                out_valid_o <= in_valid_i;
            end
        end
    end else begin
        assign out_data_o  = in_valid_i ? data_r : 'b0;
        assign out_valid_o = in_valid_i;
    end
endgenerate

endmodule
