/*
 * bit_sync.sv
 *
 *  Created on: 2021-06-09 16:38
 *      Author: Jack Chen <redchenjs@live.com>
 */

module bit_sync(
    input logic clk_i,
    input logic rst_n_i,

    input  logic bit_i,
    output logic bit_o
);

logic bit_t;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        bit_t <= 'b0;
        bit_o <= 'b0;
    end else begin
        bit_t <= bit_i;
        bit_o <= bit_t;
    end
end

endmodule
