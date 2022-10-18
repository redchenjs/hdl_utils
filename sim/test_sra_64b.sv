/*
 * test_sra_64b.sv
 *
 *  Created on: 2022-10-18 22:15
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module test_sra_64b;

parameter logic OUT_REG = 1'b1;

logic clk_i;
logic rst_n_i;

logic init_i;
logic done_o;

logic        arith_i;
logic [63:0] shift_i;

logic [63:0] data_i;
logic [63:0] data_o;

sra_64b #(
    .OUT_REG(OUT_REG)
) sra_64b (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .init_i(init_i),
    .done_o(done_o),

    .arith_i(arith_i),
    .shift_i(shift_i),

    .data_i(data_i),
    .data_o(data_o)
);

initial begin
    clk_i   = 1'b0;
    rst_n_i = 1'b0;

    init_i = 'b0;
    data_i = 'b0;

    arith_i = 'b0;
    shift_i = 'b0;

    #2 rst_n_i = 1'b1;
end

always begin
    #2.5 clk_i = ~clk_i;
end

always begin
    #5 init_i = 1'b1;
       data_i = {64{1'b1}};

    // DATA
    for (int i = 0; i < 64; i++) begin
        #5 shift_i = 1'b1 << i;
    end

    #5 arith_i = 1'b1;

    #15 data_i = 64'haaaa_5555_aaaa_5555;

    // DATA
    for (int i = 0; i < 64; i++) begin
        #5 shift_i = 1'b1 << i;
    end

    #15 data_i = 64'h5555_aaaa_5555_aaaa;

    // DATA
    for (int i = 0; i < 64; i++) begin
        #5 shift_i = 1'b1 << i;
    end

    #5 init_i = 1'b0;

    #75 rst_n_i = 1'b0;
    #25 $finish;
end

endmodule
