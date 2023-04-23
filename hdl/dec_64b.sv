/*
 * dec_64b.sv
 *
 *  Created on: 2022-10-09 18:49
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module dec_64b #(
    parameter logic OUT_REG = 1'b1
) (
    input logic clk_i,
    input logic rst_n_i,

    input  logic init_i,
    output logic done_o,

    input  logic  [5:0] data_i,
    output logic [63:0] data_o
);

logic       [7:0] dec_8b_msb;
logic [7:0] [7:0] dec_8b_lsb;

logic [63:0] data_r;

dec_8b dec_8b_la(
    .rst_n_i(init_i),

    .data_i(data_i[5:3]),
    .data_o(dec_8b_msb)
);

generate
    genvar i;
    for (i = 0; i < 8; i++) begin: gen_dec_ep
        dec_8b dec_8b_ep_i(
            .rst_n_i(dec_8b_msb[i]),

            .data_i(data_i[2:0]),
            .data_o(dec_8b_lsb[i])
        );

        assign data_r[i * 8 + 7 : i * 8] = dec_8b_lsb[i];
    end

    if (!OUT_REG) begin
        assign done_o = init_i;
        assign data_o = init_i ? data_r : 'b0;
    end else begin
        always_ff @(posedge clk_i or negedge rst_n_i)
        begin
            if (!rst_n_i) begin
                done_o <= 'b0;
                data_o <= 'b0;
            end else begin
                done_o <= init_i;
                data_o <= init_i ? data_r : data_o;
            end
        end
    end
endgenerate

endmodule
