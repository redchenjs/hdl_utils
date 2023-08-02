/*
 * test_sha256.sv
 *
 *  Created on: 2023-07-23 00:48
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module test_sha256;

parameter I_COUNT = 16;
parameter D_ITERS = 64;
parameter D_WIDTH = 32;
parameter O_COUNT = 8;

logic clk_i;
logic rst_n_i;

logic init_i;
logic last_i;
logic next_i;
logic null_o;
logic done_o;

logic [D_WIDTH-1:0] data_i;
logic [D_WIDTH-1:0] data_o;

logic [$clog2(I_COUNT)-1:0] data_cnt;

logic [I_COUNT-1:0] [D_WIDTH-1:0] data_blk_0 = {
    32'h0000_0020, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h8000_0000, 32'h0120_110a
};

logic [I_COUNT-1:0] [D_WIDTH-1:0] data_blk_1 = {
    32'h0000_0020, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h8000_0000, 32'h0120_110a
};

sha256 sha256(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i(data_i),
    .in_last_i(last_i),
    .in_valid_i(init_i),
    .in_ready_o(null_o),

    .out_data_o(data_o),
    .out_valid_o(done_o),
    .out_ready_i(next_i)
);

initial begin
    clk_i   = 'b0;
    rst_n_i = 'b0;

    #2 rst_n_i = 'b1;
end

always begin
    #2.5 clk_i = ~clk_i;
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        init_i <= 'b0;
        last_i <= 'b0;
        next_i <= 'b0;
        data_i <= 'b0;

        data_cnt <= 'b0;
    end else begin
        init_i <= null_o;
        last_i <= 'b1;
        next_i <= 'b1;
        data_i <= data_blk_0[data_cnt];

        data_cnt <= null_o ? data_cnt + 'b1 : data_cnt;
    end
end

always begin
    #7500 rst_n_i = 'b0;
    #25 $finish;
end

endmodule
