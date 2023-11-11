/*
 * dvi_tx.sv
 *
 *  Created on: 2023-11-10 00:03
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import vendor_pkg::*;

module dvi_tx #(
    parameter int VENDOR = VENDOR_XILINX
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic clk_5x_i,

    input logic             de_i,
    input logic             hsync_i,
    input logic             vsync_i,
    input logic [2:0] [7:0] pixel_i, // {r[23:16], g[15:8], b[7:0]}

    // tmds_o[0] : {clk_p, ch2_p, ch1_p, ch0_p} : {CLK_P, RED, GREEN, BLUE}
    // tmds_o[1] : {clk_n, ch2_n, ch1_n, ch0_n} : {CLK_N, RED, GREEN, BLUE}
    output logic [1:0] [3:0] tmds_o
);

logic [2:0] [9:0] par_data;
logic [2:0]       ser_data;

tmds_encoder tmds_encoder [2:0] (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .de_i({3{de_i}}),
    .c1_i({2'b0, vsync_i}),
    .c0_i({2'b0, hsync_i}),

    .d_i(pixel_i),
    .q_o(par_data)
);

par2ser_10b #(
    .VENDOR(VENDOR)
) par2ser_10b [2:0] (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .clk_5x_i(clk_5x_i),

    .par_data_i(par_data),
    .ser_data_o(ser_data)
);

generate
    case (VENDOR)
        VENDOR_XILINX: begin
            OBUFDS #(
                .SLEW("FAST"),
                .IOSTANDARD("TMDS_33")
            ) OBUFDS [3:0] (
                .I({clk_i, ser_data}),
                .O(tmds_o[0]),
                .OB(tmds_o[1])
            );
        end
        VENDOR_GOWIN: begin
            ELVDS_OBUF OBUFDS [3:0] (
                .I({clk_i, ser_data}),
                .O(tmds_o[0]),
                .OB(tmds_o[1])
            );
        end
        default: begin
            assign tmds_o = 'b0;
        end
    endcase
endgenerate

endmodule
