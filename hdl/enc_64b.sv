/*
 * enc_64b.sv
 *
 *  Created on: 2022-10-09 16:42
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module enc_64b #(
    parameter REG_OUT = 1
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [63:0] in_data_i,
    input logic        in_valid_i,

    output logic [5:0] out_data_o,
    output logic       out_valid_o
);

logic       [7:0] enc_8b_or;
logic       [2:0] enc_8b_msb;
logic [7:0] [2:0] enc_8b_lsb;

wire [5:0] data_r = {enc_8b_msb, enc_8b_lsb[enc_8b_msb]};

enc_8b enc_8b_la(
    .rst_n_i(in_valid_i),

    .data_i(enc_8b_or),
    .data_o(enc_8b_msb)
);

generate
    genvar i;
    for (i = 0; i < 8; i++) begin: gen_enc_ep
        assign enc_8b_or[i] = |in_data_i[i * 8 + 7 : i * 8];

        enc_8b enc_8b_ep_i(
            .rst_n_i(in_valid_i),

            .data_i(in_data_i[i * 8 + 7 : i * 8]),
            .data_o(enc_8b_lsb[i])
        );
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
