/*
 * ahb_decoder.sv
 *
 *  Created on: 2023-11-09 00:50
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import ahb_pkg::*;

module ahb_decoder #(
    parameter int SLV_NUMBER = 16,
    // ADDR_TABLE => '{addr_base, addr_mask}
    parameter int ADDR_TABLE[SLV_NUMBER][2] = '{
        '{32'h0000_0000, 32'hffff_0000},
        '{32'h1000_0000, 32'hffff_0000},
        '{32'h2000_0000, 32'hffff_0000},
        '{32'h3000_0000, 32'hffff_0000},
        '{32'h4000_0000, 32'hffff_0000},
        '{32'h5000_0000, 32'hffff_0000},
        '{32'h6000_0000, 32'hffff_0000},
        '{32'h7000_0000, 32'hffff_0000},
        '{32'h8000_0000, 32'hffff_0000},
        '{32'h9000_0000, 32'hffff_0000},
        '{32'ha000_0000, 32'hffff_0000},
        '{32'hb000_0000, 32'hffff_0000},
        '{32'hc000_0000, 32'hffff_0000},
        '{32'hd000_0000, 32'hffff_0000},
        '{32'he000_0000, 32'hffff_0000},
        '{32'hf000_0000, 32'hffff_0000}
    }
) (
    ahb_if.decoder s_ahb[SLV_NUMBER]
);

wire         [SLV_NUMBER-1:0] s_hsel;
wire [$clog2(SLV_NUMBER)-1:0] s_hselx;

generate
    genvar i;

    for (i = 0; i < SLV_NUMBER; i++) begin: gen_decoder
        assign s_hsel[i] = (s_ahb[i].haddr & ADDR_TABLE[i][1]) == ADDR_TABLE[i][0];

        assign s_ahb[i].hsel   = s_hsel[i];
        assign s_ahb[i].hslave = s_hselx;
    end
endgenerate

pri_64b #(
    .REG_OUT('b0)
) pri_64b (
    .clk_i('b0),
    .rst_n_i('b1),

    .in_data_i(s_hsel),
    .in_valid_i('b1),

    .out_data_o(s_hselx),
    .out_valid_o()
);

endmodule
