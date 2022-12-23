/*
 * data_sync.sv
 *
 *  Created on: 2021-06-09 16:38
 *      Author: Jack Chen <redchenjs@live.com>
 */

module data_sync #(
    parameter WIDTH = 8
) (
    input logic clk_i,
    input logic rst_n_i,

    input  logic [WIDTH-1:0] data_i,
    output logic [WIDTH-1:0] data_o
);

logic [WIDTH-1:0] data_t;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        data_t <= 'b0;
        data_o <= 'b0;
    end else begin
        data_t <= data_i;
        data_o <= data_t;
    end
end

endmodule