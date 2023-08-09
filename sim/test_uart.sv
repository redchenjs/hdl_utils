/*
 * test_uart.sv
 *
 *  Created on: 2021-07-12 15:23
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_uart;

parameter BAUD_DIV = 32'd98;

logic clk_i;
logic rst_n_i;

logic [7:0] tx_data_i;
logic       tx_valid_i;
logic       tx_ready_o;

logic tx_o;

logic [7:0] rx_data_o;
logic       rx_valid_o;
logic       rx_ready_i;

logic tx2_o;

uart_core uart_0(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .baud_div_i(BAUD_DIV),

    .in_data_i(tx_data_i),
    .in_valid_i(tx_valid_i),
    .in_ready_o(tx_ready_o),

    .out_data_o(rx_data_o),
    .out_valid_o(rx_valid_o),
    .out_ready_i(rx_ready_i),

    .rx_i(tx_o),
    .tx_o(tx_o)
);

uart_core uart_1(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .baud_div_i(BAUD_DIV),

    .in_data_i(rx_data_o),
    .in_valid_i(rx_valid_o),
    .in_ready_o(rx_ready_i),

    .out_data_o(),
    .out_valid_o(),
    .out_ready_i('b1),

    .rx_i('b1),
    .tx_o(tx2_o)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        tx_data_i  <= 8'h61;
        tx_valid_i <= 1'b1;
    end else begin
        tx_data_i  <= tx_valid_i & tx_ready_o ? tx_data_i + 1'b1 : tx_data_i;
        tx_valid_i <= tx_valid_i & tx_ready_o ? 1'b0 : 1'b1;
    end
end

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    #750000 rst_n_i <= 1'b0;
    #25 $finish;
end

endmodule
