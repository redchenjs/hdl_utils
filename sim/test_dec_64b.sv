/*
 * test_dec_64b.sv
 *
 *  Created on: 2022-10-18 22:03
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module test_dec_64b;

parameter OUT_REG = 1;

logic clk_i;
logic rst_n_i;

logic init_i;
logic done_o;

logic  [5:0] data_i;
logic [63:0] data_o;

dec_64b #(
    .OUT_REG(OUT_REG)
) dec_64b (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i(data_i),
    .in_valid_i(init_i),

    .out_data_o(data_o),
    .out_valid_o(done_o),
);

initial begin
    clk_i   <= 1'b0;
    rst_n_i <= 1'b0;

    init_i <= 'b0;
    data_i <= 'b0;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    #5 init_i <= 1'b1;

    // DATA
    for (int i = 0; i < 64; i++) begin
        #5 data_i <= i;
    end

    #5 init_i <= 1'b0;

    #75 rst_n_i <= 1'b0;
    #25 $finish;
end

endmodule
