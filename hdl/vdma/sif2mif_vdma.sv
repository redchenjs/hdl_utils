/*
 * sif2mif_vdma.sv
 *
 *  Created on: 2023-11-11 18:08
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module sif2mif_vdma #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DATA_BURST = 256,
    parameter FIFO_DEPTH = 512
) (
    // config interface
    memory_if.slave  s_memory_if,
    // stream interface (read)
    stream_if.master m_stream_if,
    // memory interface (write)
    memory_if.master m_memory_if
);

endmodule
