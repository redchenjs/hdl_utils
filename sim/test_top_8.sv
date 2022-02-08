/*
 * test_top_8.sv
 *
 *  Created on: 2022-01-06 20:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_top_8;

localparam K = 8;
localparam N = 16;
localparam D_BITS = 12;
localparam M_BITS = 16;

logic clk_i;
logic rst_n_i;

logic data_vld_i;

logic   [N-1:0] [D_BITS-1:0] data_x_i;
logic [K/2-1:0] [M_BITS-1:0] data_a_i;

logic data_rdy_o;

logic [N-1:0] [D_BITS-1:0] data_y_o;

top_8 top_8(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .data_vld_i(data_vld_i),

    .data_x_i(data_x_i),
    .data_a_i(data_a_i),

    .data_rdy_o(data_rdy_o),

    .data_y_o(data_y_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    data_vld_i <= 1'b0;

    data_x_i <= {D_BITS*N{1'b0}};
    data_a_i <= {M_BITS*K/2{1'b0}};

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    for (integer i = 0; i < N; i++) begin
        data_x_i[i] <= i;
    end

    for (integer i = 0; i < K/2; i++) begin
        data_a_i[i] <= i + 1;
    end

    data_vld_i <= 1'b1;

    for (integer n = 0; n < 65535; n++) begin
        #5 data_vld_i <= data_rdy_o ? 1'b0 : data_vld_i;

        for (integer i = 0; i < N; i++) begin
            data_x_i[i] <= data_x_i[i] + 16;
        end
    end

    #100 rst_n_i <= 1'b1;
    #25 $stop;
end

endmodule
