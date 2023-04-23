/*
 * div_64b.sv
 *
 *  Created on: 2022-10-09 15:33
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module div_64b(
    input logic clk_i,
    input logic rst_n_i,

    input  logic init_i,
    output logic done_o,

    input logic [63:0] dividend_i,
    input logic [63:0] divisor_i,

    output logic [63:0] quotient_o,
    output logic [63:0] remainder_o
);

logic        sig_quo;
logic [63:0] res_quo;

logic [63:0] res_rem;
logic [63:0] pri_rem;
logic  [5:0] enc_rem;

logic [63:0] res_div;
logic [63:0] pri_div;
logic  [5:0] enc_div;
logic [63:0] sll_div;

logic [63:0] dec_sub;

wire [63:0] abs_rem = res_rem[63] ? -res_rem : res_rem;
wire [63:0] abs_div = res_div[63] ? -res_div : res_div;
wire [63:0] abs_sll = sll_div[63] ? -sll_div : sll_div;

wire [5:0] enc_sub = enc_rem - enc_div;

wire res_upd = (abs_rem >= abs_sll);
wire res_out = (abs_rem < abs_div);
wire res_err = (res_div == 'b0);

pri_64b #(
    .OUT_REG(1'b0)
) pri_64b_rem (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .init_i(1'b1),
    .done_o(),

    .data_i(abs_rem),
    .data_o(pri_rem)
);

enc_64b #(
    .OUT_REG(1'b0)
) enc_64b_rem (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .init_i(1'b1),
    .done_o(),

    .data_i(pri_rem),
    .data_o(enc_rem)
);

pri_64b #(
    .OUT_REG(1'b0)
) pri_64b_div (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .init_i(1'b1),
    .done_o(),

    .data_i(abs_div),
    .data_o(pri_div)
);

enc_64b #(
    .OUT_REG(1'b0)
) enc_64b_div (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .init_i(1'b1),
    .done_o(),

    .data_i(pri_div),
    .data_o(enc_div)
);

dec_64b #(
    .OUT_REG(1'b0)
) dec_64b_div (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .init_i(1'b1),
    .done_o(),

    .data_i(enc_sub),
    .data_o(dec_sub)
);

sll_64b #(
    .OUT_REG(1'b0)
) sll_64b (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .init_i(1'b1),
    .done_o(),

    .shift_i(enc_sub),

    .data_i(res_div),
    .data_o(sll_div)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        done_o <= 'b1;

        sig_quo <= 'b0;
        res_quo <= 'b0;

        res_rem <= 'b0;
        res_div <= 'b0;

        quotient_o  <= 'b0;
        remainder_o <= 'b0;
    end else begin
        if (done_o) begin
            if (init_i) begin
                done_o <= 'b0;

                sig_quo <= dividend_i[63] ^ divisor_i[63];
                res_quo <= 'b0;

                res_rem <= dividend_i;
                res_div <= divisor_i;
            end
        end else begin
            done_o <= res_out | res_err;

            if (res_upd & ~res_err) begin
                res_quo <= res_quo + (sig_quo ? -dec_sub : dec_sub);
                res_rem <= res_rem - (sig_quo ? -sll_div : sll_div);
            end else begin
                res_quo <= res_quo + (sig_quo ? -{dec_sub[63], dec_sub[63:1]} : {dec_sub[63], dec_sub[63:1]});
                res_rem <= res_rem - (sig_quo ? -{sll_div[63], sll_div[63:1]} : {sll_div[63], sll_div[63:1]});
            end

            quotient_o  <= (res_out | res_err) ? res_quo : quotient_o;
            remainder_o <= (res_out | res_err) ? res_rem : remainder_o;
        end
    end
end

endmodule
