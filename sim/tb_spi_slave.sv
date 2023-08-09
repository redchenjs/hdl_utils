/*
 * tb_spi_slave.sv
 *
 *  Created on: 2020-07-08 15:07
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module tb_spi_slave;

logic clk_i;
logic rst_n_i;

logic sclk_i;
logic mosi_i;
logic miso_o;
logic cs_n_i;

logic init_i;
logic done_o;

logic [7:0] data_i;
logic [7:0] data_o;

spi_slave spi_slave(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i(data_i),
    .in_valid_i(init_i),

    .out_data_o(data_o),
    .out_valid_o(done_o),

    .sclk_i(sclk_i),
    .mosi_i(mosi_i),
    .miso_o(miso_o),
    .cs_n_i(cs_n_i)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    cs_n_i <= 1'b1;
    sclk_i <= 1'b0;
    mosi_i <= 1'b0;

    init_i <= 1'b0;
    data_i <= 8'h6e;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always @(negedge clk_i) begin
    init_i <= done_o ? 'b1 : 'b0;
    data_i <= done_o ? data_i + 'b1 : data_i;
end

always begin
    #50 cs_n_i <= 1'b0;

    // 0x2A
    #15 sclk_i <= 1'b0;
        mosi_i <= 1'b0;  // BIT7
    #15 sclk_i <= 1'b1;

    #15 sclk_i <= 1'b0;
        mosi_i <= 1'b0;  // BIT6
    #15 sclk_i <= 1'b1;

    #15 sclk_i <= 1'b0;
        mosi_i <= 1'b1;  // BIT5
    #15 sclk_i <= 1'b1;

    #15 sclk_i <= 1'b0;
        mosi_i <= 1'b0;  // BIT4
    #15 sclk_i <= 1'b1;

    #15 sclk_i <= 1'b0;
        mosi_i <= 1'b1;  // BIT3
    #15 sclk_i <= 1'b1;

    #15 sclk_i <= 1'b0;
        mosi_i <= 1'b0;  // BIT2
    #15 sclk_i <= 1'b1;

    #15 sclk_i <= 1'b0;
        mosi_i <= 1'b1;  // BIT1
    #15 sclk_i <= 1'b1;

    #15 sclk_i <= 1'b0;
        mosi_i <= 1'b0;  // BIT0
    #15 sclk_i <= 1'b1;

    // 0x2B
    #15 sclk_i <= 1'b0;
        mosi_i <= 1'b0;  // BIT7
    #15 sclk_i <= 1'b1;

    #15 sclk_i <= 1'b0;
        mosi_i <= 1'b0;  // BIT6
    #15 sclk_i <= 1'b1;

    #15 sclk_i <= 1'b0;
        mosi_i <= 1'b1;  // BIT5
    #15 sclk_i <= 1'b1;

    #15 sclk_i <= 1'b0;
        mosi_i <= 1'b0;  // BIT4
    #15 sclk_i <= 1'b1;

    #15 sclk_i <= 1'b0;
        mosi_i <= 1'b1;  // BIT3
    #15 sclk_i <= 1'b1;

    #15 sclk_i <= 1'b0;
        mosi_i <= 1'b0;  // BIT2
    #15 sclk_i <= 1'b1;

    #15 sclk_i <= 1'b0;
        mosi_i <= 1'b1;  // BIT1
    #15 sclk_i <= 1'b1;

    #15 sclk_i <= 1'b0;
        mosi_i <= 1'b1;  // BIT0
    #15 sclk_i <= 1'b1;

    for (integer i = 0; i < 1024; i++) begin
        #15 sclk_i <= 1'b0;
            mosi_i <= 1'b0;
        #15 sclk_i <= 1'b1;
    end

    #15 sclk_i <= 1'b0;

    #25 cs_n_i <= 1'b1;

    #75 rst_n_i <= 1'b0;
    #25 $finish;
end

endmodule
