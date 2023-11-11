/*
 * dvi_rx.sv
 *
 *  Created on: 2023-11-11 17:45
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import vendor_pkg::*;

module dvi_rx #(
    parameter int VENDOR = VENDOR_XILINX
) (
    input logic rst_n_i,

    // tmds_o[0] : {clk_p, ch2_p, ch1_p, ch0_p} : {CLK_P, RED, GREEN, BLUE}
    // tmds_o[1] : {clk_n, ch2_n, ch1_n, ch0_n} : {CLK_N, RED, GREEN, BLUE}
    input logic [1:0] [3:0] tmds_i,

    output logic             de_o,
    output logic             hsync_o,
    output logic             vsync_o,
    output logic [2:0] [7:0] pixel_o, // {r[23:16], g[15:8], b[7:0]}

    output logic clk_o,
    output logic clk_5x_o
);

logic [2:0]       ser_data;
logic [2:0] [9:0] par_data;

generate
    case (VENDOR)
        VENDOR_XILINX: begin

        end
        VENDOR_GOWIN: begin

        end
        default: begin
            assign ser_data = 'b0;
        end
    endcase
endgenerate

ser2par_10b #(
    .VENDOR(VENDOR)
) ser2par_10b [2:0] (
    .rst_n_i(rst_n_i),

    .ser_data_i(ser_data),
    .par_data_o(par_data),

    .clk_o(clk_o),
    .clk_5x_o(clk_5x_o)
);

tmds_decoder tmds_decoder [2:0] (
    .clk_i(clk_o),
    .rst_n_i(rst_n_i),

    .q_i(par_data),
    .d_o(pixel_i),

    .de_o(de_o),
    .c1_o(vsync_o),
    .c0_o(hsync_o)
);

endmodule
