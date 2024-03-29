/*
 * rst_sync.sv
 *
 *  Created on: 2020-05-07 18:57
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module rst_sync(
    input logic clk_i,

    input  logic rst_n_i,
    output logic rst_n_o
);

logic rst_n_t;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rst_n_t <= 'b0;
        rst_n_o <= 'b0;
    end else begin
        rst_n_t <= 'b1;
        rst_n_o <= rst_n_t;
    end
end

endmodule
