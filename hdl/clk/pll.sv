/*
 * pll.sv
 *
 *  Created on: 2023-11-13 16:04
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import vendor_pkg::*;

module pll #(
    parameter int VENDOR  = VENDOR_XILINX,
    parameter int CLK_REF = 100000000,
    parameter int CLK_MUL = 5,
    parameter int CLK_DIV = 1,
    parameter int CLK_PHA = 0
) (
    input logic clk_i,
    input logic rst_n_i,

    output logic clk_o,
    output logic rst_n_o
);

logic clk_fb;

generate
    case (VENDOR)
        VENDOR_XILINX: begin
            PLLE2_BASE #(
                .BANDWIDTH("OPTIMIZED"),
                .CLKFBOUT_MULT(CLK_MUL*2),
                .CLKFBOUT_PHASE(0.0),
                .CLKIN1_PERIOD(1000000000/CLK_REF),
                .CLKOUT0_DIVIDE(CLK_DIV*2),
                .CLKOUT1_DIVIDE(1),
                .CLKOUT2_DIVIDE(1),
                .CLKOUT3_DIVIDE(1),
                .CLKOUT4_DIVIDE(1),
                .CLKOUT5_DIVIDE(1),
                .CLKOUT0_DUTY_CYCLE(0.5),
                .CLKOUT1_DUTY_CYCLE(0.5),
                .CLKOUT2_DUTY_CYCLE(0.5),
                .CLKOUT3_DUTY_CYCLE(0.5),
                .CLKOUT4_DUTY_CYCLE(0.5),
                .CLKOUT5_DUTY_CYCLE(0.5),
                .CLKOUT0_PHASE(CLK_PHA),
                .CLKOUT1_PHASE(0.0),
                .CLKOUT2_PHASE(0.0),
                .CLKOUT3_PHASE(0.0),
                .CLKOUT4_PHASE(0.0),
                .CLKOUT5_PHASE(0.0),
                .DIVCLK_DIVIDE(1),
                .REF_JITTER1(0.0),
                .STARTUP_WAIT("TRUE")
            ) PLL(
                .CLKOUT0(clk_o),
                .CLKOUT1(),
                .CLKOUT2(),
                .CLKOUT3(),
                .CLKOUT4(),
                .CLKOUT5(),
                .CLKFBOUT(clk_fb),
                .LOCKED(rst_n_o),
                .CLKIN1(clk_i),
                .PWRDWN(1'b0),
                .RST(~rst_n_i),
                .CLKFBIN(clk_fb)
            );
        end
        VENDOR_GOWIN: begin

        end
        default: begin
            assign clk_o   = clk_i;
            assign rst_n_o = rst_n_i;
        end
    endcase
endgenerate

endmodule
