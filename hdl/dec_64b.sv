/*
 * dec_64b.sv
 *
 *  Created on: 2022-10-09 18:49
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module dec_64b #(
    parameter REG_OUT = 1
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic  [5:0] in_data_i,
    input logic        in_valid_i,

    output logic [63:0] out_data_o,
    output logic        out_valid_o
);

logic       [7:0] dec_8b_msb;
logic [7:0] [7:0] dec_8b_lsb;

logic [63:0] data_r;

dec_8b dec_8b_la(
    .rst_n_i(in_valid_i),

    .data_i(in_data_i[5:3]),
    .data_o(dec_8b_msb)
);

generate
    genvar i;
    for (i = 0; i < 8; i++) begin: gen_dec_ep
        dec_8b dec_8b_ep_i(
            .rst_n_i(dec_8b_msb[i]),

            .data_i(in_data_i[2:0]),
            .data_o(dec_8b_lsb[i])
        );

        assign data_r[i * 8 + 7 : i * 8] = dec_8b_lsb[i];
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
