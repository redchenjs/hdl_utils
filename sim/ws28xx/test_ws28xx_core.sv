/*
 * test_ws28xx_core.sv
 *
 *  Created on: 2020-07-08 21:15
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_ws28xx_core;

logic clk_i;
logic rst_n_i;

logic out_sync_i;

logic [7:0] reg_t0h_time_i;
logic [8:0] reg_t0s_time_i;
logic [7:0] reg_t1h_time_i;
logic [8:0] reg_t1s_time_i;

logic [3:0] ram_wr_en_i;
logic [7:0] ram_wr_addr_i;
logic [7:0] ram_wr_data_i;

logic bit_code_o;

ws28xx_core ws28xx_core(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .out_sync_i(out_sync_i),

    .reg_t0h_time_i(reg_t0h_time_i),
    .reg_t0s_time_i(reg_t0s_time_i),
    .reg_t1h_time_i(reg_t1h_time_i),
    .reg_t1s_time_i(reg_t1s_time_i),

    .ram_wr_en_i(ram_wr_en_i),
    .ram_wr_addr_i(ram_wr_addr_i),
    .ram_wr_data_i(ram_wr_data_i),

    .bit_code_o(bit_code_o)
);

initial begin
    clk_i   <= 'b1;
    rst_n_i <= 'b0;

    reg_t0h_time_i <= 8'h00;
    reg_t0s_time_i <= 9'h00f;
    reg_t1h_time_i <= 8'h01;
    reg_t1s_time_i <= 9'h00f;

    out_sync_i <= 'b0;

    ram_wr_en_i   <= 4'b0000;
    ram_wr_addr_i <= 8'h00;
    ram_wr_data_i <= 8'h00;

    #2 rst_n_i <= 'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    // ADDR 0
    #11 ram_wr_addr_i <= 8'h00;
        ram_wr_data_i <= 8'h01;
        ram_wr_en_i <= 4'b1000;
    #5  ram_wr_en_i <= 'b0;

    #10 ram_wr_data_i <= 8'haa;
        ram_wr_en_i <= 4'b0101;
    #5  ram_wr_en_i <= 'b0;

    #10 ram_wr_data_i <= 8'h55;
        ram_wr_en_i <= 4'b0010;
    #5  ram_wr_en_i <= 'b0;

    // ADDR 1
    #10 ram_wr_addr_i <= 8'h01;
        ram_wr_data_i <= 8'h02;
        ram_wr_en_i <= 4'b1000;
    #5  ram_wr_en_i <= 'b0;

    #10 ram_wr_data_i <= 8'h77;
        ram_wr_en_i <= 4'b0101;
    #5  ram_wr_en_i <= 'b0;

    #10 ram_wr_data_i <= 8'hff;
        ram_wr_en_i <= 4'b0010;
    #5  ram_wr_en_i <= 'b0;

    // ADDR 2
    #10 ram_wr_addr_i <= 8'h02;
        ram_wr_data_i <= 8'h03;
        ram_wr_en_i <= 4'b1000;
    #5  ram_wr_en_i <= 'b0;

    #10 ram_wr_data_i <= 8'h99;
        ram_wr_en_i <= 4'b0101;
    #5  ram_wr_en_i <= 'b0;

    #10 ram_wr_data_i <= 8'h00;
        ram_wr_en_i <= 4'b0010;
    #5  ram_wr_en_i <= 'b0;

    // ADDR 3
    #10 ram_wr_addr_i <= 8'h03;
        ram_wr_data_i <= 8'h00;
        ram_wr_en_i <= 4'b1000;
    #5  ram_wr_en_i <= 'b0;

    #10 ram_wr_data_i <= 8'hcc;
        ram_wr_en_i <= 4'b0101;
    #5  ram_wr_en_i <= 'b0;

    #10 ram_wr_data_i <= 8'h33;
        ram_wr_en_i <= 4'b0010;
    #5  ram_wr_en_i <= 'b0;

    #10 out_sync_i <= 'b1;
    #5  out_sync_i <= 'b0;

    for (int i = 0; i < 65536; i++) begin
        #5 out_sync_i <= 'b1;
        #5 out_sync_i <= 'b0;
    end

    for (int i = 0; i < 1024; i++) begin
        #5 out_sync_i <= 'b0;
    end

    #75 rst_n_i <= 'b0;
    #25 $stop;
end

endmodule
