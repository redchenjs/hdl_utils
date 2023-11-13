/*
 * ser2par_10b.sv
 *
 *  Created on: 2023-11-11 17:45
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import vendor_pkg::*;

module ser2par_10b #(
    parameter int VENDOR = VENDOR_XILINX
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic clk_5x_i,
    input logic cal_en_i,

    input  logic       ser_data_i,
    output logic [9:0] par_data_o
);

generate
    case (VENDOR)
        VENDOR_XILINX: begin
            logic shiftout1;
            logic shiftout2;

            ISERDESE2 #(
                .DATA_RATE("DDR"),
                .DATA_WIDTH(10),
                .DYN_CLKDIV_INV_EN("FALSE"),
                .DYN_CLK_INV_EN("FALSE"),
                .INIT_Q1(1'b0),
                .INIT_Q2(1'b0),
                .INIT_Q3(1'b0),
                .INIT_Q4(1'b0),
                .INTERFACE_TYPE("NETWORKING"),
                .IOBDELAY("NONE"),
                .NUM_CE(1),
                .OFB_USED("FALSE"),
                .SERDES_MODE("MASTER"),
                .SRVAL_Q1(1'b0),
                .SRVAL_Q2(1'b0),
                .SRVAL_Q3(1'b0),
                .SRVAL_Q4(1'b0)
            ) ISERDES_M(
                .O(),
                .Q1(par_data_o[0]),
                .Q2(par_data_o[1]),
                .Q3(par_data_o[2]),
                .Q4(par_data_o[3]),
                .Q5(par_data_o[4]),
                .Q6(par_data_o[5]),
                .Q7(par_data_o[6]),
                .Q8(par_data_o[7]),
                .SHIFTOUT1(shiftout1),
                .SHIFTOUT2(shiftout2),
                .BITSLIP(cal_en_i),
                .CE1(1'b1),
                .CLKDIVP(1'b0),
                .CLK(clk_5x_i),
                .CLKB(~clk_5x_i),
                .CLKDIV(clk_i),
                .OCLK(1'b0),
                .DYNCLKDIVSEL(1'b0),
                .DYNCLKSEL(1'b0),
                .D(ser_data_i),
                .DDLY(1'b0),
                .OFB(1'b0),
                .OCLKB(1'b0),
                .RST(~rst_n_i),
                .SHIFTIN1(1'b0),
                .SHIFTIN2(1'b0)
            );

            ISERDESE2 #(
                .DATA_RATE("DDR"),
                .DATA_WIDTH(10),
                .DYN_CLKDIV_INV_EN("FALSE"),
                .DYN_CLK_INV_EN("FALSE"),
                .INIT_Q1(1'b0),
                .INIT_Q2(1'b0),
                .INIT_Q3(1'b0),
                .INIT_Q4(1'b0),
                .INTERFACE_TYPE("NETWORKING"),
                .IOBDELAY("NONE"),
                .NUM_CE(1),
                .OFB_USED("FALSE"),
                .SERDES_MODE("SLAVE"),
                .SRVAL_Q1(1'b0),
                .SRVAL_Q2(1'b0),
                .SRVAL_Q3(1'b0),
                .SRVAL_Q4(1'b0)
            ) ISERDES_S(
                .O(),
                .Q1(),
                .Q2(),
                .Q3(par_data_o[8]),
                .Q4(par_data_o[9]),
                .Q5(),
                .Q6(),
                .Q7(),
                .Q8(),
                .SHIFTOUT1(),
                .SHIFTOUT2(),
                .BITSLIP(cal_en_i),
                .CE1(1'b1),
                .CLKDIVP(1'b0),
                .CLK(clk_5x_i),
                .CLKB(~clk_5x_i),
                .CLKDIV(clk_i),
                .OCLK(1'b0),
                .DYNCLKDIVSEL(1'b0),
                .DYNCLKSEL(1'b0),
                .D(1'b0),
                .DDLY(1'b0),
                .OFB(1'b0),
                .OCLKB(1'b0),
                .RST(~rst_n_i),
                .SHIFTIN1(shiftout1),
                .SHIFTIN2(shiftout2)
            );
        end
        VENDOR_GOWIN: begin
            IDES10 #(
                .GSREN("false"),
                .LSREN("true")
            ) ISERDES(
                .Q0(par_data_o[0]),
                .Q1(par_data_o[1]),
                .Q2(par_data_o[2]),
                .Q3(par_data_o[3]),
                .Q4(par_data_o[4]),
                .Q5(par_data_o[5]),
                .Q6(par_data_o[6]),
                .Q7(par_data_o[7]),
                .Q8(par_data_o[8]),
                .Q9(par_data_o[9]),
                .D(ser_data_i),
                .FCLK(clk_5x_i),
                .PCLK(clk_i),
                .CALIB(cal_en_i),
                .RESET(~rst_n_i)
            );
        end
        default: begin
            assign par_data_o = 'b0;
        end
    endcase
endgenerate

endmodule
