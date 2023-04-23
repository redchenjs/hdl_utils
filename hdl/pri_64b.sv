/*
 * pri_64b.sv
 *
 *  Created on: 2022-10-09 15:40
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module pri_64b #(
    parameter logic OUT_REG = 1'b1
) (
    input logic clk_i,
    input logic rst_n_i,

    input  logic init_i,
    output logic done_o,

    input  logic [63:0] data_i,
    output logic [63:0] data_o
);

logic [7:0] pri_8b_or;
logic [7:0] pri_8b_ep;

logic [63:0] data_r;

pri_8b pri_8b_la(
    .rst_n_i(init_i),

    .data_i(pri_8b_or),
    .data_o(pri_8b_ep)
);

generate
    genvar i;
    for (i = 0; i < 8; i++) begin: gen_pri_ep
        assign pri_8b_or[i] = |data_i[i * 8 + 7 : i * 8];

        pri_8b pri_8b_ep_i(
            .rst_n_i(pri_8b_ep[i]),

            .data_i(data_i[i * 8 + 7 : i * 8]),
            .data_o(data_r[i * 8 + 7 : i * 8])
        );
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
