/*
 * dvi_rx.sv
 *
 *  Created on: 2023-11-11 17:45
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import vendor_pkg::*;

module dvi_rx #(
    parameter int REFCLK = 74250000,
    parameter int VENDOR = VENDOR_XILINX
) (
    input logic rst_n_i,

    // tmds_o[0] : {clk_p, ch2_p, ch1_p, ch0_p} : {CLK, RED, GREEN, BLUE}
    // tmds_o[1] : {clk_n, ch2_n, ch1_n, ch0_n} : {CLK, RED, GREEN, BLUE}
    input logic [1:0] [3:0] tmds_i,

    output logic             de_o,
    output logic             vsync_o,
    output logic             hsync_o,
    output logic [2:0] [7:0] pixel_o, // {r[23:16], g[15:8], b[7:0]}

    output logic clk_o
);

logic clk_5x;
logic pll_rst_n;

logic [2:0] [2:0] ctrl;

logic [2:0]       ser_data;
logic [2:0] [9:0] par_data;

assign de_o    = ctrl[2][0];
assign vsync_o = ctrl[1][0];
assign hsync_o = ctrl[0][0];

generate
    case (VENDOR)
        VENDOR_XILINX: begin
            IBUFDS #(
                .DIFF_TERM("FALSE"),
                .IOSTANDARD("TMDS_33"),
                .IBUF_LOW_PWR("FALSE")
            ) IBUFDS [3:0] (
                .O({clk_o, ser_data}),
                .I(tmds_i[0]),
                .IB(tmds_i[1])
            );
        end
        VENDOR_GOWIN: begin
            ELVDS_IBUF IBUFDS [3:0] (
                .O({clk_o, ser_data}),
                .I(tmds_i[0]),
                .IB(tmds_i[1])
            );
        end
        default: begin
            assign {clk_o, ser_data} = 'b0;
        end
    endcase
endgenerate

pll #(
    .VENDOR(VENDOR),
    .CLK_REF(REFCLK),
    .CLK_MUL(5),
    .CLK_DIV(1),
    .CLK_PHA(0)
) pll(
    .clk_i(clk_o),
    .rst_n_i(rst_n_i),

    .clk_o(clk_5x),
    .rst_n_o(pll_rst_n)
);

ser2par_10b #(
    .VENDOR(VENDOR)
) ser2par_10b [2:0] (
    .clk_i(clk_o),
    .rst_n_i(rst_n_i & pll_rst_n),

    .clk_5x_i(clk_5x),
    .cal_en_i(cal_en_i),

    .ser_data_i(ser_data),
    .par_data_o(par_data)
);

tmds_decoder tmds_decoder [2:0] (
    .clk_i(clk_o),
    .rst_n_i(rst_n_i & pll_rst_n),

    .d_i(par_data),
    .q_o(pixel_o),

    .de_o(ctrl[2]),
    .c1_o(ctrl[1]),
    .c0_o(ctrl[0])
);

endmodule
