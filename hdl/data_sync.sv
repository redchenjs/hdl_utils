/*
 * data_sync.sv
 *
 *  Created on: 2021-06-09 16:38
 *      Author: Jack Chen <redchenjs@live.com>
 */

module data_sync(
    input logic clk_i,
    input logic rst_n_i,

    input  logic data_i,
    output logic data_o
);

logic data_t;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        data_t <= 1'b0;
        data_o <= 1'b0;
    end else begin
        data_t <= data_i;
        data_o <= data_t;
    end
end

endmodule
