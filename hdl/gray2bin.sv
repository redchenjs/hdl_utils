/*
 * gray2bin.sv
 *
 *  Created on: 2022-12-24 02:30
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module gray2bin #(
    parameter WIDTH = 8,
    parameter OUT_REG = 1
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [WIDTH-1:0] in_data_i,
    input logic             in_valid_i,

    output logic [WIDTH-1:0] out_data_o,
    output logic             out_valid_o
);

logic [WIDTH-1:0] data_t;

always_comb begin
    data_t[WIDTH-1] = in_data_i[WIDTH-1];

    for (int i = WIDTH-2; i >= 0; i--) begin
        data_t[i] = in_data_i[i] ^ data_t[i + 1];
    end
end

generate
    if (!OUT_REG) begin
        assign out_data_o  = in_valid_i ? data_t : 'b0;
        assign out_valid_o = in_valid_i;
    end else begin
        always_ff @(posedge clk_i or negedge rst_n_i)
        begin
            if (!rst_n_i) begin
                out_data_o  <= 'b0;
                out_valid_o <= 'b0;
            end else begin
                out_data_o  <= in_valid_i ? data_t : out_data_o;
                out_valid_o <= in_valid_i;
            end
        end
    end
endgenerate

endmodule
