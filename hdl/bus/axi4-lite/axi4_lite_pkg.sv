/*
 * axi4_lite_pkg.sv
 *
 *  Created on: 2023-11-06 00:55
 *      Author: Jack Chen <redchenjs@live.com>
 */

package axi4_lite_pkg;
    typedef logic [3:0] axi_id_t;

    typedef enum logic [2:0] {
        AXI_PROT_PRIVILEGED  = 3'b001,
        AXI_PROT_NON_SECURE  = 3'b010,
        AXI_PROT_INSTRUCTION = 3'b100
    } ahb_prot_t;

    typedef enum logic [1:0] {
        AXI_RESP_OKAY   = 2'b00,
        AXI_RESP_EXOKAY = 2'b01,
        AXI_RESP_SLVERR = 2'b10,
        AXI_RESP_DECERR = 2'b11
    } axi_resp_t;
endpackage
