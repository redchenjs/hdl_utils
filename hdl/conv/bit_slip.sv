/*
 * bit_slip.sv
 *
 *  Created on: 2023-11-13 22:35
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import vendor_pkg::*;

module bit_slip #(
    parameter int VENDOR     = VENDOR_XILINX,
    parameter int SYNC_PATTE = 32'h0000_0000,
    parameter int SYNC_COUNT = 10,
    parameter int DATA_WIDTH = 10
) (
    input logic clk_i,
    input logic rst_n_i,

    input  logic [DATA_WIDTH-1:0] data_i,
    output logic [DATA_WIDTH-1:0] data_o,

    output logic sync_o
);

logic       [DATA_WIDTH*2-1:0] data_t;
logic         [DATA_WIDTH-1:0] data_m;
logic           [DATA_WIDTH:0] data_p;

logic                          sync_t;
logic [$clog2(DATA_WIDTH)-1:0] sync_c;

generate
    genvar i;

    for (i = 0; i < DATA_WIDTH; i++) begin
        assign data_m[i] = data_t[i+:DATA_WIDTH];
        assign data_p[i] = (SYNC_PATTE == data_m[i]);
    end
endgenerate

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        data_t <= 'b0;
        data_o <= 'b0;

        sync_c <= 'b0;
        sync_t <= 'b0;
        sync_o <= 'b0;
    end else begin
        data_t <= {data_t[DATA_WIDTH+:DATA_WIDTH], data_i};
        data_o <= 'b0;

        sync_c <= sync_t & data_p ? sync_c + 1'b1 : sync_c;
        sync_t <= sync_c == (SYNC_COUNT - 'b1);
        sync_o <= sync_t;
    end
end

endmodule
