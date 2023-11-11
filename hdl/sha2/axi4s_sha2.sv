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

stream_if #(
    .DATA_WIDTH(I_WIDTH),
    .USER_WIDTH(U_WIDTH)
) s_sif();

stream_if #(
    .DATA_WIDTH(O_WIDTH),
    .USER_WIDTH(U_WIDTH)
) m_sif();

axis2sif axis2sif(
    .s_axis(s_axi4s),
    .m_sif(s_sif)
);

sif_sha2 sif_sha2(
    .s_sif(s_sif),
    .m_sif(m_sif)
);

sif2axis sif2axis(
    .s_sif(m_sif),
    .m_axis(m_axi4s)
);

endmodule
