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
    input logic rst_n_i,

    input  logic       ser_data_i,
    output logic [9:0] par_data_o,

    output logic clk_o,
    output logic clk_5x_o
);

generate
    case (VENDOR)
        VENDOR_XILINX: begin
            
        end
        VENDOR_GOWIN: begin

        end
        default: begin
            assign par_data_o = 'b0;
        end
    endcase
endgenerate

endmodule
