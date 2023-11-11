/*
 * par2ser_10b.sv
 *
 *  Created on: 2022-03-03 15:55
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import vendor_pkg::*;

module par2ser_10b #(
    parameter int VENDOR = VENDOR_XILINX
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic clk_5x_i,

    input  logic [9:0] par_data_i,
    output logic       ser_data_o
);

generate
    case (VENDOR)
        VENDOR_XILINX: begin
            logic shiftin1;
            logic shiftin2;

            OSERDESE2 #(
                .DATA_RATE_OQ("DDR"),
                .DATA_RATE_TQ("DDR"),
                .DATA_WIDTH(10),
                .INIT_OQ(1'b0),
                .INIT_TQ(1'b0),
                .SERDES_MODE("MASTER"),
                .SRVAL_OQ(1'b0),
                .SRVAL_TQ(1'b0),
                .TBYTE_CTL("FALSE"),
                .TBYTE_SRC("FALSE"),
                .TRISTATE_WIDTH(1)
            ) OSERDES_M(
                .OFB(),
                .OQ(ser_data_o),
                .SHIFTOUT1(),
                .SHIFTOUT2(),
                .TBYTEOUT(),
                .TFB(),
                .TQ(),
                .CLK(clk_5x_i),
                .CLKDIV(clk_i),
                .D1(par_data_i[0]),
                .D2(par_data_i[1]),
                .D3(par_data_i[2]),
                .D4(par_data_i[3]),
                .D5(par_data_i[4]),
                .D6(par_data_i[5]),
                .D7(par_data_i[6]),
                .D8(par_data_i[7]),
                .OCE(1'b1),
                .RST(~rst_n_i),
                .SHIFTIN1(shiftin1),
                .SHIFTIN2(shiftin2),
                .T1(1'b0),
                .T2(1'b0),
                .T3(1'b0),
                .T4(1'b0),
                .TBYTEIN(1'b0),
                .TCE(1'b0)
            );

            OSERDESE2 #(
                .DATA_RATE_OQ("DDR"),
                .DATA_RATE_TQ("DDR"),
                .DATA_WIDTH(10),
                .INIT_OQ(1'b0),
                .INIT_TQ(1'b0),
                .SERDES_MODE("SLAVE"),
                .SRVAL_OQ(1'b0),
                .SRVAL_TQ(1'b0),
                .TBYTE_CTL("FALSE"),
                .TBYTE_SRC("FALSE"),
                .TRISTATE_WIDTH(1)
            ) OSERDES_S(
                .OFB(),
                .OQ(),
                .SHIFTOUT1(shiftin1),
                .SHIFTOUT2(shiftin2),
                .TBYTEOUT(),
                .TFB(),
                .TQ(),
                .CLK(clk_5x_i),
                .CLKDIV(clk_i),
                .D1(1'b0),
                .D2(1'b0),
                .D3(par_data_i[8]),
                .D4(par_data_i[9]),
                .D5(1'b0),
                .D6(1'b0),
                .D7(1'b0),
                .D8(1'b0),
                .OCE(1'b1),
                .RST(~rst_n_i),
                .SHIFTIN1(1'b0),
                .SHIFTIN2(1'b0),
                .T1(1'b0),
                .T2(1'b0),
                .T3(1'b0),
                .T4(1'b0),
                .TBYTEIN(1'b0),
                .TCE(1'b0)
            );
        end
        VENDOR_GOWIN: begin
            OSER10 #(
                .GSREN("false"),
                .LSREN("true")
            ) OSERDES(
                .Q(ser_data_o),
                .D0(par_data_i[0]),
                .D1(par_data_i[1]),
                .D2(par_data_i[2]),
                .D3(par_data_i[3]),
                .D4(par_data_i[4]),
                .D5(par_data_i[5]),
                .D6(par_data_i[6]),
                .D7(par_data_i[7]),
                .D8(par_data_i[8]),
                .D9(par_data_i[9]),
                .PCLK(clk_i),
                .FCLK(clk_5x_i),
                .RESET(~rst_n_i)
            );
        end
        default: begin
            assign ser_data_o = 'b0;
        end
    endcase
endgenerate

endmodule
