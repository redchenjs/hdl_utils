/*
 * pri_64b.sv
 *
 *  Created on: 2022-10-09 15:40
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module pri_64b #(
    parameter OUT_REG = 1
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [63:0] in_data_i,
    input logic        in_valid_i,

    output logic [63:0] out_data_o,
    output logic        out_valid_o
);

logic [7:0] pri_8b_or;
logic [7:0] pri_8b_ep;

logic [63:0] data_r;

pri_8b pri_8b_la(
    .rst_n_i(in_valid_i),

    .data_i(pri_8b_or),
    .data_o(pri_8b_ep)
);

generate
    genvar i;
    for (i = 0; i < 8; i++) begin: gen_pri_ep
        assign pri_8b_or[i] = |in_data_i[i * 8 + 7 : i * 8];

        pri_8b pri_8b_ep_i(
            .rst_n_i(pri_8b_ep[i]),

            .data_i(in_data_i[i * 8 + 7 : i * 8]),
            .data_o(data_r[i * 8 + 7 : i * 8])
        );
    end

    if (!OUT_REG) begin
        assign out_data_o  = in_valid_i ? data_r : 'b0;
        assign out_valid_o = in_valid_i;
    end else begin
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
    end
endgenerate

endmodule
