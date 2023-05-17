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

logic tx_2_o;

uart_tx uart_tx(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .init_i(tx_valid_i),
    .done_o(tx_ready_o),

    .data_i(tx_data_i),
    .data_o(tx_o),

    .baud_div_i(BAUD_DIV)
);

uart_rx uart_rx(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .init_i(rx_ready_i),
    .done_o(rx_valid_o),

    .data_i(tx_o),
    .data_o(rx_data_o),

    .baud_div_i(BAUD_DIV)
);

uart_tx uart_tx_2(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .init_i(rx_valid_o),
    .done_o(rx_ready_i),

    .data_i(rx_data_o),
    .data_o(tx_2_o),

    .baud_div_i(BAUD_DIV)
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
