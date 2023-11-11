/*
 * ahb_sha2.sv
 *
 *  Created on: 2021-08-22 18:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module ahb_sha2 #(
    parameter A_WIDTH = 32,
    parameter D_WIDTH = 32
) (
    ahb_if.slave s_ahb,
    output logic s_irq
);

memory_if #(
    .ADDR_WIDTH(A_WIDTH),
    .DATA_WIDTH(D_WIDTH)
) mif();

ahb2mif #(
    .ADDR_WIDTH(A_WIDTH),
    .DATA_WIDTH(D_WIDTH)
) ahb2mif(
    .s_ahb(s_ahb),
    .m_mif(mif)
);

mif_sha2 #(
    .A_WIDTH(A_WIDTH),
    .D_WIDTH(D_WIDTH),
    .I_DEPTH(32),
    .O_DEPTH(2)
) mif_sha2(
    .s_mif(mif),
    .s_irq(s_irq)
);

endmodule
