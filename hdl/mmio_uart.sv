/*
 * mmio_uart.sv
 *
 *  Created on: 2021-08-22 18:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module mmio_uart #(
    parameter A_WIDTH = 8,
    parameter D_WIDTH = 32,
    parameter I_DEPTH = 16,
    parameter O_DEPTH = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic               wr_en_i,
    input logic [A_WIDTH-1:0] wr_addr_i,
    input logic [D_WIDTH-1:0] wr_data_i,

    input  logic               rd_en_i,
    input  logic [A_WIDTH-1:0] rd_addr_i,
    output logic [D_WIDTH-1:0] rd_data_o,

    input  logic rx_i,
    output logic tx_o
);

typedef enum logic [1:0] {
    UART_REG_CTRL_0  = 2'h0,
    UART_REG_CTRL_1  = 2'h1,
    UART_REG_DATA_TX = 2'h2,
    UART_REG_DATA_RX = 2'h3
} uart_reg_t;

typedef struct packed {
    logic [31:0] baud;
} uart_ctrl_0_t;

typedef struct packed {
    logic [7:0] rsvd_3;
    logic [7:0] rsvd_2;
    logic [7:0] rsvd_1;

    logic [7:1] rsvd_0;
    logic       rst_n;
} uart_ctrl_1_t;

typedef struct packed {
    logic [7:0] rsvd_2;
    logic [7:0] rsvd_1;

    logic [7:1] rsvd_0;
    logic       tx_flag;

    logic [7:0] tx_data;
} uart_data_tx_t;

typedef struct packed {
    logic [7:0] rsvd_2;
    logic [7:0] rsvd_1;

    logic [7:1] rsvd_0;
    logic       rx_flag;

    logic [7:0] rx_data;
} uart_data_rx_t;

logic [7:0] tx_data;
logic       tx_valid;
logic       tx_ready;

logic [7:0] rx_data;
logic       rx_valid;
logic       rx_ready;

uart_ctrl_0_t uart_ctrl_0;
uart_ctrl_1_t uart_ctrl_1;

uart_data_tx_t uart_data_tx;
uart_data_rx_t uart_data_rx;

assign uart_data_tx.tx_data = tx_data;
assign uart_data_tx.tx_flag = tx_ready;
assign uart_data_rx.rx_data = rx_data;
assign uart_data_rx.rx_flag = rx_valid;

logic [D_WIDTH-1:0] regs[4];

assign regs[UART_REG_CTRL_0]  = uart_ctrl_0;
assign regs[UART_REG_CTRL_1]  = uart_ctrl_1;
assign regs[UART_REG_DATA_TX] = uart_data_tx;
assign regs[UART_REG_DATA_RX] = uart_data_rx;

uart #(
    .D_WIDTH(D_WIDTH),
    .I_DEPTH(I_DEPTH),
    .O_DEPTH(O_DEPTH)
) uart (
    .clk_i(clk_i),
    .rst_n_i(uart_ctrl_1.rst_n),

    .baud_div_i(uart_ctrl_0.baud),

    .in_data_i(tx_data),
    .in_valid_i(tx_valid),
    .in_ready_o(tx_ready),

    .out_data_o(rx_data),
    .out_valid_o(rx_valid),
    .out_ready_i(rx_ready),

    .rx_i(rx_i),
    .tx_o(tx_o)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        tx_data  <= 'b0;
        tx_valid <= 'b0;

        rd_data_o <= 'b0;

        uart_ctrl_0.baud  <= 'b0;
        uart_ctrl_1.rst_n <= 'b0;
    end else begin
        rd_data_o <= rd_en_i ? regs[rd_addr_i[3:2]] : rd_data_o;

        if (wr_en_i & |wr_byte_en_i) begin
            case (wr_addr_i[3:2])
                UART_REG_CTRL_0: begin
                    uart_ctrl_0.baud <= wr_data_i;
                end
                UART_REG_CTRL_1: begin
                    uart_ctrl_1.rst_n <= wr_data_i[0];
                end
                UART_REG_DATA_TX: begin
                    tx_data  <= wr_data_i[7:0];
                    tx_valid <= 'b1;
                end
                default;
            endcase
        end else begin
            tx_valid <= tx_ready ? 'b0 : tx_valid;
        end
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rx_ready <= 'b0;
    end else begin
        rx_ready <= rx_valid ? (rd_en_i & (rd_addr_i[3:2] == UART_REG_DATA_RX) ? 'b1 : rx_ready) : 'b0;
    end
end

endmodule
