/*
 * axi4s_sha2.sv
 *
 *  Created on: 2021-08-22 18:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module axi4s_sha2(
    axi4_stream_if.slave  s_axi4s,
    axi4_stream_if.master m_axi4s
);

parameter U_WIDTH = 2;
parameter I_WIDTH = 64;
parameter O_WIDTH = 512;

pipe_if #(
    .DATA_WIDTH(I_WIDTH),
    .USER_WIDTH(U_WIDTH)
) i_pipe();

pipe_if #(
    .DATA_WIDTH(O_WIDTH),
    .USER_WIDTH(U_WIDTH)
) o_pipe();

axi4s_pipe_bridge axi4s_pipe_bridge(
    .s_axi4s(s_axi4s),
    .o_pipe(i_pipe)
);

pipe_axi4s_bridge pipe_axi4s_bridge(
    .i_pipe(o_pipe),
    .m_axi4s(m_axi4s)
);

pipe_sha2 pipe_sha2(
    .i_pipe(i_pipe),
    .o_pipe(o_pipe)
);

endmodule
