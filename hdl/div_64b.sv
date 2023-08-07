/*
 * div_64b.sv
 *
 *  Created on: 2022-10-09 15:33
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module div_64b #(
    parameter D_WIDTH = 64
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [1:0] [D_WIDTH-1:0] in_data_i,    // {dividend, divisor}
    input logic                     in_valid_i,

    output logic [1:0] [D_WIDTH-1:0] out_data_o,  // {quotient, remainder}
    output logic                     out_valid_o
);

logic               sig_quo;
logic [D_WIDTH-1:0] res_quo;

logic         [D_WIDTH-1:0] res_rem;
logic         [D_WIDTH-1:0] pri_rem;
logic [$clog2(D_WIDTH)-1:0] enc_rem;

logic         [D_WIDTH-1:0] res_div;
logic         [D_WIDTH-1:0] pri_div;
logic [$clog2(D_WIDTH)-1:0] enc_div;
logic         [D_WIDTH-1:0] sll_div;

logic [D_WIDTH-1:0] dec_sub;

wire [D_WIDTH-1:0] abs_rem = res_rem[D_WIDTH-1] ? -res_rem : res_rem;
wire [D_WIDTH-1:0] abs_div = res_div[D_WIDTH-1] ? -res_div : res_div;
wire [D_WIDTH-1:0] abs_sll = sll_div[D_WIDTH-1] ? -sll_div : sll_div;

wire [$clog2(D_WIDTH)-1:0] enc_sub = enc_rem - enc_div;

wire res_upd = (abs_rem >= abs_sll);
wire res_out = (abs_rem < abs_div);
wire res_err = (res_div == 'b0);

pri_64b #(
    .REG_OUT(1'b0)
) pri_64b_rem (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i(abs_rem),
    .in_valid_i('b1),

    .out_data_o(pri_rem),
    .out_valid_o()
);

enc_64b #(
    .REG_OUT(1'b0)
) enc_64b_rem (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i(pri_rem),
    .in_valid_i('b1),

    .out_data_o(enc_rem),
    .out_valid_o()
);

pri_64b #(
    .REG_OUT(1'b0)
) pri_64b_div (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i(abs_div),
    .in_valid_i('b1),

    .out_data_o(pri_div),
    .out_valid_o()
);

enc_64b #(
    .REG_OUT(1'b0)
) enc_64b_div (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i(pri_div),
    .in_valid_i('b1),

    .out_data_o(enc_div),
    .out_valid_o()
);

dec_64b #(
    .REG_OUT(1'b0)
) dec_64b_div (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i(enc_sub),
    .in_valid_i('b1),

    .out_data_o(dec_sub),
    .out_valid_o()
);

shl_64b #(
    .REG_OUT(1'b0)
) shl_64b (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .carry_i('b0),
    .shift_i(enc_sub),

    .in_data_i(res_div),
    .in_valid_i('b1),

    .out_data_o(sll_div),
    .out_valid_o()
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        sig_quo <= 'b0;
        res_quo <= 'b0;

        res_rem <= 'b0;
        res_div <= 'b0;

        out_data_o  <= 'b0;
        out_valid_o <= 'b1;
    end else begin
        if (out_valid_o) begin
            if (in_valid_i) begin
                sig_quo <= in_data_i[1][D_WIDTH-1] ^ in_data_i[0][D_WIDTH-1];
                res_quo <= 'b0;

                res_rem <= in_data_i[1];
                res_div <= in_data_i[0];

                out_valid_o <= 'b0;
            end
        end else begin
            if (res_upd & ~res_err) begin
                res_quo <= res_quo + (sig_quo ? -dec_sub : dec_sub);
                res_rem <= res_rem - (sig_quo ? -sll_div : sll_div);
            end else begin
                res_quo <= res_quo + (sig_quo ? -{dec_sub[D_WIDTH-1], dec_sub[D_WIDTH-1:1]} : {dec_sub[D_WIDTH-1], dec_sub[D_WIDTH-1:1]});
                res_rem <= res_rem - (sig_quo ? -{sll_div[D_WIDTH-1], sll_div[D_WIDTH-1:1]} : {sll_div[D_WIDTH-1], sll_div[D_WIDTH-1:1]});
            end

            out_data_o[1] <= (res_out | res_err) ? res_quo : out_data_o[1];
            out_data_o[0] <= (res_out | res_err) ? res_rem : out_data_o[0];
            out_valid_o   <= (res_out | res_err);
        end
    end
end

endmodule
