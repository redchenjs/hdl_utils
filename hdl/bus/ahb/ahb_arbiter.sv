/*
 * ahb_arbiter.sv
 *
 *  Created on: 2023-11-09 00:50
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import ahb_pkg::*;

module ahb_arbiter #(
    parameter int MAS_NUMBER = 16
) (
    ahb_if.arbiter m_ahb[MAS_NUMBER]
);

wire [MAS_NUMBER-1:0] m_hlock;
wire [MAS_NUMBER-1:0] m_hgrant;

wire         [MAS_NUMBER-1:0] m_hbusreq;
wire [$clog2(MAS_NUMBER)-1:0] m_hbusreqx;

generate
    genvar i;

    for (i = 0; i < MAS_NUMBER; i++) begin: gen_arbiter
        assign m_hlock[i] = m_ahb[i].hlock;
        assign m_hbusreq[i] = m_ahb[i].hbusreq;

        assign m_ahb[i].hmaster = m_hbusreqx;
        assign m_ahb[i].hmastlock = |m_hlock;

        assign m_ahb[i].hgrant = m_hgrant[i];
    end
endgenerate

pri_64b #(
    .REG_OUT('b0)
) pri_64b (
    .clk_i(m_ahb[0].hclk),
    .rst_n_i(m_ahb[0].hresetn),

    .in_data_i(m_hbusreq),
    .in_valid_i('b1),

    .out_data_o(m_hbusreqx),
    .out_valid_o()
);

dec_64b #(
    .REG_OUT('b0)
) dec_64b (
    .clk_i(m_ahb[0].hclk),
    .rst_n_i(m_ahb[0].hresetn),

    .in_data_i(m_hbusreqx),
    .in_valid_i('b1),

    .out_data_o(m_hgrant),
    .out_valid_o()
);

endmodule
