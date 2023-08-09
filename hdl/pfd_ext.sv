/*
 * pfd_ext.sv
 *
 *  Created on: 2023-08-03 03:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module pfd_ext #(
    parameter CNT_WIDTH = 16,
    parameter DIV_WIDTH = 8
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic sig_a_i,
    input logic sig_b_i,

    output logic p_ext_sign_o,
    output logic p_ext_diff_o,

    output logic f_ext_half_o
);

logic sig_a_p;
logic sig_a_n;

logic sig_b_p;
logic sig_b_n;

logic cnt_a_p;
logic cnt_a_n;

logic cnt_b_p;
logic cnt_b_n;

logic                 cnt_done;
logic                 cnt_sign;
logic [CNT_WIDTH-1:0] cnt_diff;
logic [CNT_WIDTH-1:0] cnt_half;

logic                 cnt_sign_r1;
logic [CNT_WIDTH-1:0] cnt_diff_r1;
logic [CNT_WIDTH-1:0] cnt_half_r1;

logic                 cnt_sign_r2;
logic [CNT_WIDTH-1:0] cnt_diff_r2;
logic [CNT_WIDTH-1:0] cnt_half_r2;

logic [CNT_WIDTH+DIV_WIDTH:0] out_cnt;
logic                         out_done;

edge2en sig_a_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(sig_a_i),
    .pos_edge_o(sig_a_p),
    .neg_edge_o(sig_a_n)
);

edge2en sig_b_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(sig_b_i),
    .pos_edge_o(sig_b_p),
    .neg_edge_o(sig_b_n)
);

edge2en out_done_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(out_cnt == {cnt_half_r2, {DIV_WIDTH{1'b0}}, 1'b0}),
    .pos_edge_o(out_done)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        cnt_a_p <= 'b0;
        cnt_a_n <= 'b0;

        cnt_b_p <= 'b0;
        cnt_b_n <= 'b0;

        cnt_done <= 'b0;
        cnt_sign <= 'b0;
        cnt_diff <= 'b0;
        cnt_half <= 'b0;

        cnt_sign_r1 <= 'b0;
        cnt_diff_r1 <= 'b0;
        cnt_half_r1 <= 'b0;

        cnt_sign_r2 <= 'b0;
        cnt_diff_r2 <= 'b0;
        cnt_half_r2 <= 'b0;

        out_cnt <= 'b0;

        p_ext_sign_o <= 'b0;
        p_ext_diff_o <= 'b0;

        f_ext_half_o <= 'b0;
    end else begin
        cnt_a_p <= sig_a_p ? 'b1 : (cnt_done ? 'b0 : cnt_a_p);
        cnt_a_n <= sig_a_n ? 'b1 : (cnt_done ? 'b0 : cnt_a_n);

        cnt_b_p <= sig_b_p ? 'b1 : (cnt_done ? 'b0 : cnt_b_p);
        cnt_b_n <= sig_b_n ? 'b1 : (cnt_done ? 'b0 : cnt_b_n);

        cnt_done <= cnt_done ? 'b0 : ( cnt_a_n &  cnt_b_n  ?            'b1 : cnt_done);
        cnt_sign <= cnt_done ? 'b0 : (~cnt_a_p &  cnt_b_p  ?            'b1 : cnt_sign);
        cnt_diff <= cnt_done ? 'b0 : ( cnt_a_p ^  cnt_b_p  ? cnt_diff + 'b1 : cnt_diff);
        cnt_half <= cnt_done ? 'b0 : ( cnt_a_p & ~cnt_a_n  ? cnt_half + 'b1 : cnt_half);

        cnt_sign_r1 <= cnt_done ? cnt_sign : cnt_sign_r1;
        cnt_diff_r1 <= cnt_done ? cnt_diff : cnt_diff_r1;
        cnt_half_r1 <= cnt_done ? cnt_half : cnt_half_r1;

        cnt_sign_r2 <= out_done ? cnt_sign_r1 : cnt_sign_r2;
        cnt_diff_r2 <= out_done ? cnt_diff_r1 : cnt_diff_r2;
        cnt_half_r2 <= out_done ? cnt_half_r1 : cnt_half_r2;
 
        out_cnt <= out_done ? 'b0 : out_cnt + 'b1;

        p_ext_sign_o <=  out_done ? cnt_sign_r2 : p_ext_sign_o;
        p_ext_diff_o <= ~out_done & (out_cnt < {cnt_diff_r2, {DIV_WIDTH{1'b0}}});

        f_ext_half_o <= ~out_done & (out_cnt < {cnt_half_r2, {DIV_WIDTH{1'b0}}});
    end
end

endmodule
