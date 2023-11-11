/*
 * mif2sif_vdma.sv
 *
 *  Created on: 2022-04-07 15:57
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module mif2sif_vdma #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_BURST = 256,
    parameter FIFO_DEPTH = 512
) (
    // config interface
    memory_if.slave  s_memory_if,
    // memory interface (read)
    memory_if.master m_memory_if,
    // stream interface (write)
    stream_if.master m_stream_if
);

endmodule
