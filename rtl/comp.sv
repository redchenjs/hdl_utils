/*
 * comp.sv
 *
 *  Created on: 2022-01-06 16:04
 *      Author: Jack Chen <redchenjs@live.com>
 */

module comp #(
    parameter K = 8,
    parameter N = 16,
    parameter D_BITS = 12,
    parameter M_BITS = 16
) (
    input logic   [K-1:0] [D_BITS-1:0] x_i,
    input logic [K/2-1:0] [M_BITS-1:0] a_i,

    output logic [D_BITS-1:0] y_o
);

always_comb begin
    y_o = (x_i[0] + x_i[K-1]) * a_i[0];

    for (integer i = 1; i < K/2; i++) begin
        y_o += (x_i[i] + x_i[K-1-i]) * a_i[i];
    end
end

endmodule
