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

generate
    case (VENDOR)
        VENDOR_XILINX: begin
            logic clk_fb;

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
            rPLL #(
                .FCLKIN($sformatf("%0.3f", CLK_REF/1000000)),
                .DYN_IDIV_SEL("false"),
                .IDIV_SEL(CLK_DIV),
                .DYN_FBDIV_SEL("false"),
                .FBDIV_SEL(CLK_MUL*2-1),
                .ODIV_SEL(2),
                .PSDA_SEL("0000"),
                .DYN_DA_EN("false"),
                .DUTYDA_SEL("1000"),
                .CLKOUT_FT_DIR(1'b1),
                .CLKOUTP_FT_DIR(1'b1),
                .CLKOUT_DLY_STEP(0),
                .CLKOUTP_DLY_STEP(0),
                .CLKFB_SEL("internal"),
                .CLKOUT_BYPASS("false"),
                .CLKOUTP_BYPASS("false"),
                .CLKOUTD_BYPASS("false"),
                .DYN_SDIV_SEL(2),
                .CLKOUTD_SRC("CLKOUT"),
                .CLKOUTD3_SRC("CLKOUT"),
                .DEVICE("")
            ) PLL(
                .CLKOUT(clk_o),
                .LOCK(rst_n_o),
                .CLKOUTP(),
                .CLKOUTD(),
                .CLKOUTD3(),
                .RESET(~rst_n_i),
                .RESET_P(~rst_n_i),
                .CLKIN(clk_i),
                .CLKFB('b0),
                .FBDSEL('b0),
                .IDSEL('b0),
                .ODSEL('b0),
                .PSDA('b0),
                .DUTYDA('b0),
                .FDLY('b0)
            );
        end
        default: begin
            assign clk_o   = clk_i;
            assign rst_n_o = rst_n_i;
        end
    endcase
endgenerate

endmodule
