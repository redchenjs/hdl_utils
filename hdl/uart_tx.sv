/*
 * uart_tx.sv
 *
 *  Created on: 2021-07-12 13:02
 *      Author: Jack Chen <redchenjs@live.com>
 */

module uart_tx(
    input logic clk_i,
    input logic rst_n_i,

    input  logic init_i,
    output logic done_o,

    input  logic [7:0] data_i,
    output logic       data_o,

    input logic [31:0] baud_div_i
);

typedef enum logic [1:0] {
    IDLE  = 2'h0,
    START = 2'h1,
    DATA  = 2'h2,
    STOP  = 2'h3
} state_t;

state_t ctl_sta;

logic        clk_s;
logic [31:0] clk_cnt;

logic [2:0] bit_sel;
logic [7:0] bit_sft;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        clk_s   <= 'b0;
        clk_cnt <= 'b0;
    end else begin
        clk_s   <= (clk_cnt == baud_div_i);
        clk_cnt <= (ctl_sta == IDLE) | clk_s ? 'b0 : clk_cnt + 'b1;
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        done_o <= 'b1;
    end else begin
        done_o <= init_i & done_o ? 'b0 : (clk_s & (ctl_sta == STOP) ? 'b1 : done_o);
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        ctl_sta <= IDLE;

        bit_sel <= 'b0;
        bit_sft <= 'b0;

        data_o <= 'b1;
    end else begin
        case (ctl_sta)
            IDLE:
                ctl_sta <= init_i ? START : ctl_sta;
            START:
                ctl_sta <= clk_s ? DATA : ctl_sta;
            DATA:
                ctl_sta <= clk_s & (bit_sel == 3'h7) ? STOP : ctl_sta;
            STOP:
                ctl_sta <= clk_s ? IDLE : ctl_sta;
            default:
                ctl_sta <= IDLE;
        endcase

        case (ctl_sta)
            START: begin
                bit_sel <= clk_s ? 'b0 : bit_sel;
                bit_sft <= clk_s ? data_i : bit_sft;
            end
            DATA: begin
                bit_sel <= clk_s ? bit_sel + 'b1 : bit_sel;
                bit_sft <= clk_s ? {1'b0, bit_sft[7:1]} : bit_sft;
            end
            default: begin
                bit_sel <= bit_sel;
                bit_sft <= bit_sft;
            end
        endcase

        data_o <= bit_sft[0] | (ctl_sta == IDLE) | (ctl_sta == STOP);
    end
end

endmodule