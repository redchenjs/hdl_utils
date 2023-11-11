/*
 * axi4s_vdma.sv
 *
 *  Created on: 2022-04-07 15:57
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import axi4_lite_pkg::*;

module axi4s_vdma #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_BURST = 256,
    parameter FIFO_DEPTH = 512
) (
    // config interface
    axi4_lite_if.slave  s_axi4l_if,
    // memory interface
    axi4_lite_if.master m_axi4l_if,
    // stream interface
    axi4_stream_if.master m_axi4s_if
);

endmodule
