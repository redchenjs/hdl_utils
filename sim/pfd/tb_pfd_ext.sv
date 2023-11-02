/*
 * tb_pfd_ext.sv
 *
 *  Created on: 2023-08-03 03:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module tb_pfd_ext;

logic clk_i;
logic rst_n_i;

logic sig_a_i;
logic sig_b_i;

logic p_ext_sign_o;
logic p_ext_diff_o;

logic f_ext_half_o;

pfd_ext pfd_ext(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .sig_a_i(sig_a_i),
    .sig_b_i(sig_b_i),

    .p_ext_sign_o(p_ext_sign_o),
    .p_ext_diff_o(p_ext_diff_o),

    .f_ext_half_o(f_ext_half_o)
);

initial begin
    clk_i   <= 'b1;
    rst_n_i <= 'b0;

    #2 rst_n_i <= 'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    sig_a_i <= 'b0;
    sig_b_i <= 'b0;

    for (int i = 0; i < 2000; i++) begin
        #480 sig_a_i <= ~sig_a_i;
        # 20 sig_b_i <= ~sig_b_i;
    end

    sig_a_i <= 'b0;
    sig_b_i <= 'b0;

    for (int i = 0; i < 2000; i++) begin
        #480 sig_b_i <= ~sig_b_i;
        # 20 sig_a_i <= ~sig_a_i;
    end

    #75 rst_n_i <= 'b0;

    #25 $finish;
end

endmodule
