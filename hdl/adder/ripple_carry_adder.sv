/*
 * ripple_carry_adder.sv
 *
 *  Created on: 2023-11-24 14:10
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module ripple_carry_adder #(
    parameter int D_WIDTH = 64
) (
    input logic [D_WIDTH-1:0] a_i,
    input logic [D_WIDTH-1:0] b_i,
    input logic               c_i,

    output logic [D_WIDTH-1:0] s_o,
    output logic               c_o
);

logic [D_WIDTH:0] c_t;

generate
    genvar i;

    assign c_t[0] = c_i;
    assign c_o    = c_t[D_WIDTH];

    for (i = 0; i < D_WIDTH; i++) begin
        full_adder full_adder(
            .a_i(a_i[i]),
            .b_i(b_i[i]),
            .c_i(c_t[i]),

            .s_o(s_o[i]),
            .c_o(c_t[i+1])
        );
    end
endgenerate

endmodule
