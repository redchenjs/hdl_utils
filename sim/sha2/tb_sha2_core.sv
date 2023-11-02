/*
 * tb_sha2_core.sv
 *
 *  Created on: 2023-07-23 00:48
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module tb_sha2_core;

parameter I_WIDTH = 64;
parameter O_WIDTH = 512;

logic clk_i;
logic rst_n_i;

logic [1:0] mode_i;
logic       last_i;

logic init_i;
logic next_i;
logic null_o;
logic done_o;

logic [I_WIDTH-1:0] data_i;
logic [O_WIDTH-1:0] data_o;

logic [7:0] data_cnt;

logic [15:0] [31:0] data_blk_0 = {
    32'h2000_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h0000_0080, 32'h0a11_2001
};

logic [15:0] [31:0] data_blk_1 = {
    32'h2002_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
    32'h0000_0000, 32'h0000_0000, 32'h0000_0080, 32'h0a11_2001
};

sha2_core sha2_core(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_mode_i(mode_i),
    .in_last_i(last_i),

    .in_data_i(data_i),
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

assign data_i = (data_cnt >= 'h10) ? {data_blk_1[data_cnt[3:0]], 32'b0} : {data_blk_0[data_cnt[3:0]], 32'b0};
//assign data_i = (data_cnt >= 'h10) ? {data_blk_1[data_cnt[3:0]+1], data_blk_1[data_cnt[3:0]]} : {data_blk_0[data_cnt[3:0]+1], data_blk_0[data_cnt[3:0]]};
assign mode_i = (data_cnt == 'h00) ? 2'b01 : 2'b00;
assign last_i = (data_cnt == 'h1f);
//assign last_i = (data_cnt == 'h1e);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        init_i <= 'b0;
        next_i <= 'b0;

        data_cnt <= 'b0;
    end else begin
        init_i <= null_o;
        next_i <= 'b1;

        data_cnt <= init_i ? data_cnt + 'd1 : data_cnt;
//        data_cnt <= init_i ? data_cnt + 'd2 : data_cnt;
    end
end

always begin
    #7500 rst_n_i = 'b0;
    #25 $finish;
end

endmodule
