/*
 * test_ws28xx_gen.sv
 *
 *  Created on: 2020-07-08 20:03
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_ws28xx_gen;

logic clk_i;
logic rst_n_i;

logic bit_data_i;
logic bit_valid_i;
logic bit_ready_o;

logic [7:0] reg_t0h_time_i;
logic [8:0] reg_t0s_time_i;
logic [7:0] reg_t1h_time_i;
logic [8:0] reg_t1s_time_i;

logic bit_code_o;

ws28xx_gen ws28xx_gen(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .bit_data_i(bit_data_i),
    .bit_valid_i(bit_valid_i),
    .bit_ready_o(bit_ready_o),

    .reg_t0h_time_i(reg_t0h_time_i),
    .reg_t0s_time_i(reg_t0s_time_i),
    .reg_t1h_time_i(reg_t1h_time_i),
    .reg_t1s_time_i(reg_t1s_time_i),

    .bit_code_o(bit_code_o)
);

initial begin
    clk_i   <= 'b1;
    rst_n_i <= 'b0;

    bit_data_i  <= 'b0;
    bit_valid_i <= 'b0;

    reg_t0h_time_i <= 8'h00;
    reg_t0s_time_i <= 9'h001;
    reg_t1h_time_i <= 8'h01;
    reg_t1s_time_i <= 9'h001;

    #2 rst_n_i <= 'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    #11 bit_data_i  <= 'b0;
        bit_valid_i <= 'b1;

    #5  bit_valid_i <= 'b0;

    for (int i = 0; i < 10; i++) begin
        #25 bit_data_i  <= i % 2;
            bit_valid_i <= 1'b1;

        #5  bit_valid_i  <= 1'b0;
    end

    #75 rst_n_i <= 1'b0;
    #25 $stop;
end

endmodule
