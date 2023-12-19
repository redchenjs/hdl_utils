/*
 * ahb_interconnect.sv
 *
 *  Created on: 2023-11-09 00:16
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

import ahb_pkg::*;

module ahb_interconnect #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 64,
    parameter int MAS_NUMBER = 16,
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
    ahb_if.br_master m_ahb[MAS_NUMBER],
    ahb_if.br_slave  s_ahb[SLV_NUMBER]
);

logic [ADDR_WIDTH-1:0] m_haddr[MAS_NUMBER];
ahb_trans_t            m_htrans[MAS_NUMBER];
logic                  m_hwrite[MAS_NUMBER];
ahb_size_t             m_hsize[MAS_NUMBER];
ahb_burst_t            m_hburst[MAS_NUMBER];
ahb_prot_t             m_hprot[MAS_NUMBER];
logic [DATA_WIDTH-1:0] m_hwdata[MAS_NUMBER];

logic [DATA_WIDTH-1:0] s_hrdata[SLV_NUMBER];
logic                  s_hready[SLV_NUMBER];
ahb_resp_t             s_hresp[SLV_NUMBER];

ahb_if #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) m_ahb_if[MAS_NUMBER]();

ahb_if #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) s_ahb_if[SLV_NUMBER]();

ahb_arbiter #(
    .MAS_NUMBER(MAS_NUMBER)
) ahb_arbiter (
    .m_ahb(m_ahb_if)
);

ahb_decoder #(
    .SLV_NUMBER(SLV_NUMBER),
    .ADDR_TABLE(ADDR_TABLE)
) ahb_decoder (
    .s_ahb(s_ahb_if)
);

generate
    genvar i;

    for (i = 0; i < MAS_NUMBER; i++) begin
        // assign master interface
        assign m_ahb_if[i].haddr   = m_ahb[i].haddr;
        assign m_ahb_if[i].htrans  = m_ahb[i].htrans;
        assign m_ahb_if[i].hwrite  = m_ahb[i].hwrite;
        assign m_ahb_if[i].hsize   = m_ahb[i].hsize;
        assign m_ahb_if[i].hburst  = m_ahb[i].hburst;
        assign m_ahb_if[i].hprot   = m_ahb[i].hprot;
        assign m_ahb_if[i].hwdata  = m_ahb[i].hwdata;
        assign m_ahb_if[i].hbusreq = m_ahb[i].hbusreq;
        assign m_ahb_if[i].hlock   = m_ahb[i].hlock;

        assign m_ahb[i].hgrant = m_ahb_if[i].hgrant;
        assign m_ahb[i].hrdata = m_ahb_if[i].hrdata;
        assign m_ahb[i].hready = m_ahb_if[i].hready;
        assign m_ahb[i].hresp  = m_ahb_if[i].hresp;

        // generate master mutipliexor
        assign m_haddr[i]  = m_ahb_if[i].haddr;
        assign m_htrans[i] = m_ahb_if[i].htrans;
        assign m_hwrite[i] = m_ahb_if[i].hwrite;
        assign m_hsize[i]  = m_ahb_if[i].hsize;
        assign m_hburst[i] = m_ahb_if[i].hburst;
        assign m_hprot[i]  = m_ahb_if[i].hprot;
        assign m_hwdata[i] = m_ahb_if[i].hwdata;

        assign m_ahb_if[i].hrdata = s_hrdata[s_ahb_if[0].hslave];
        assign m_ahb_if[i].hready = s_hready[s_ahb_if[0].hslave];
        assign m_ahb_if[i].hresp  = s_hresp[s_ahb_if[0].hslave];
    end

    for (i = 0; i < SLV_NUMBER; i++) begin
        // assign slave interface
        assign s_ahb[i].hsel      = s_ahb_if[i].hsel;
        assign s_ahb[i].haddr     = s_ahb_if[i].haddr;
        assign s_ahb[i].htrans    = s_ahb_if[i].htrans;
        assign s_ahb[i].hwrite    = s_ahb_if[i].hwrite;
        assign s_ahb[i].hsize     = s_ahb_if[i].hsize;
        assign s_ahb[i].hburst    = s_ahb_if[i].hburst;
        assign s_ahb[i].hprot     = s_ahb_if[i].hprot;
        assign s_ahb[i].hwdata    = s_ahb_if[i].hwdata;
        assign s_ahb[i].hmaster   = s_ahb_if[i].hmaster;
        assign s_ahb[i].hmastlock = s_ahb_if[i].hmastlock;

        assign s_ahb_if[i].hsplitx = s_ahb[i].hsplitx;
        assign s_ahb_if[i].hrdata  = s_ahb[i].hrdata;
        assign s_ahb_if[i].hready  = s_ahb[i].hready;
        assign s_ahb_if[i].hresp   = s_ahb[i].hresp;

        // generate slave mutipliexor
        assign s_ahb_if[i].haddr  = m_haddr[m_ahb_if[0].hmaster];
        assign s_ahb_if[i].htrans = m_htrans[m_ahb_if[0].hmaster];
        assign s_ahb_if[i].hwrite = m_hwrite[m_ahb_if[0].hmaster];
        assign s_ahb_if[i].hsize  = m_hsize[m_ahb_if[0].hmaster];
        assign s_ahb_if[i].hburst = m_hburst[m_ahb_if[0].hmaster];
        assign s_ahb_if[i].hprot  = m_hprot[m_ahb_if[0].hmaster];
        assign s_ahb_if[i].hwdata = m_hwdata[m_ahb_if[0].hmaster];

        assign s_hrdata[i] = s_ahb_if[i].hrdata;
        assign s_hready[i] = s_ahb_if[i].hready;
        assign s_hresp[i]  = s_ahb_if[i].hresp;
    end
endgenerate

endmodule
