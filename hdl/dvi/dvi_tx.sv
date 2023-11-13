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
    input logic             vsync_i,
    input logic             hsync_i,
    input logic [2:0] [7:0] pixel_i, // {r[23:16], g[15:8], b[7:0]}

    // tmds_o[0] : {clk_p, ch2_p, ch1_p, ch0_p} : {CLK, RED, GREEN, BLUE}
    // tmds_o[1] : {clk_n, ch2_n, ch1_n, ch0_n} : {CLK, RED, GREEN, BLUE}
    output logic [1:0] [3:0] tmds_o
);

logic clk_5x;
logic pll_rst_n;

logic [2:0] [2:0] ctrl;

logic [2:0] [9:0] par_data;
logic [2:0]       ser_data;

assign ctrl[2] = {3{de_i}};
assign ctrl[1] = {2'b0, vsync_i};
assign ctrl[0] = {2'b0, hsync_i};

pll #(
    .VENDOR(VENDOR_XILINX),
    .CLK_REF(100000000),
    .CLK_MUL(5),
    .CLK_DIV(1),
    .CLK_PHA(0)
) pll(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .clk_o(clk_5x),
    .rst_n_o(pll_rst_n)
);

tmds_encoder tmds_encoder [2:0] (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i & pll_rst_n),

    .de_i(ctrl[2]),
    .c1_i(ctrl[1]),
    .c0_i(ctrl[0]),

    .d_i(pixel_i),
    .q_o(par_data)
);

par2ser_10b #(
    .VENDOR(VENDOR)
) par2ser_10b [2:0] (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i & pll_rst_n),

    .clk_5x_i(clk_5x),

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
