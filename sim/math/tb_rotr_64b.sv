/*
 * tb_rotr_64b.sv
 *
 *  Created on: 2023-07-22 20:04
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module tb_rotr_64b;

parameter REG_OUT = 1;

logic clk_i;
logic rst_n_i;

logic init_i;
logic done_o;

logic [5:0] shift_i;

logic [63:0] data_i;
logic [63:0] data_o;

rotr_64b #(
    .REG_OUT(REG_OUT)
) rotr_64b (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .shift_i(shift_i),

    .in_data_i(data_i),
    .in_valid_i(init_i),

    .out_data_o(data_o),
    .out_valid_o(done_o)
);

initial begin
    clk_i   = 'b0;
    rst_n_i = 'b0;

    init_i = 'b0;
    data_i = 'b0;

    shift_i = 'b0;

    #2 rst_n_i = 'b1;
end

always begin
    #2.5 clk_i = ~clk_i;
end

always begin
    #5 init_i = 'b1;
       data_i = 64'h0123_4567_89ab_cdef;

    // DATA
    for (int i = 0; i < 64; i++) begin
        #5 shift_i = i;
    end

    #15 data_i = 64'hfedc_ba98_7654_3210;

    // DATA
    for (int i = 0; i < 64; i++) begin
        #5 shift_i = i;
    end

    #5 init_i = 'b0;

    #75 rst_n_i = 'b0;
    #25 $finish;
end

endmodule
