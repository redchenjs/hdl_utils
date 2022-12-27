/*
 * mmio_uart.sv
 *
 *  Created on: 2021-08-22 18:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module mmio_uart #(
    parameter XLEN = 32,
    parameter BASE = 32'h4000_0000
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [XLEN-1:0] rd_addr_i,
    inout wire  [XLEN-1:0] rd_data_io,

    input logic         [XLEN-1:0] wr_addr_i,
    input logic         [XLEN-1:0] wr_data_i,
    input logic [$clog2(XLEN)-1:0] wr_byte_en_i,

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

logic [XLEN-1:0] regs[4];

logic [XLEN-1:0] rd_data;
logic            rd_en_r1;

uart_ctrl_0_t uart_ctrl_0;
uart_ctrl_1_t uart_ctrl_1;

uart_data_tx_t uart_data_tx;
uart_data_rx_t uart_data_rx;

wire rd_en = (rd_addr_i[31:8] == BASE[31:8]);
wire wr_en = (wr_addr_i[31:8] == BASE[31:8]);

assign regs[UART_REG_CTRL_0]  = uart_ctrl_0;
assign regs[UART_REG_CTRL_1]  = uart_ctrl_1;
assign regs[UART_REG_DATA_TX] = uart_data_tx;
assign regs[UART_REG_DATA_RX] = uart_data_rx;

assign uart_data_tx.tx_data = tx_data;
assign uart_data_tx.tx_flag = tx_ready;
assign uart_data_rx.rx_data = rx_data;
assign uart_data_rx.rx_flag = rx_valid;

assign rd_data_io = rd_en_r1 ? rd_data : {XLEN{1'bz}};

uart_tx uart_tx(
    .clk_i(clk_i),
    .rst_n_i(uart_ctrl_1.rst_n),

    .init_i(tx_valid),
    .done_o(tx_ready),

    .data_i(tx_data),
    .data_o(tx_o),

    .baud_div_i(uart_ctrl_0.baud)
);

uart_rx uart_rx(
    .clk_i(clk_i),
    .rst_n_i(uart_ctrl_1.rst_n),

    .init_i(rx_ready),
    .done_o(rx_valid),

    .data_i(rx_i),
    .data_o(rx_data),

    .baud_div_i(uart_ctrl_0.baud)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rd_data <= 'b0;

        uart_ctrl_0.baud  <= 'b0;
        uart_ctrl_1.rst_n <= 'b0;

        tx_data  <= 'b0;
        tx_valid <= 'b0;
    end else begin
        rd_data <= rd_en ? regs[rd_addr_i[3:2]] : rd_data;

        if (wr_en & |wr_byte_en_i) begin
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
        rx_ready <= rx_valid ? (rd_en & (rd_addr_i[3:2] == UART_REG_DATA_RX) ? 'b1 : rx_ready) : 'b0;
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rd_en_r1 <= 'b0;
    end else begin
        rd_en_r1 <= rd_en;
    end
end

endmodule
