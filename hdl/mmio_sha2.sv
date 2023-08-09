/*
 * mmio_sha2.sv
 *
 *  Created on: 2023-08-09 11:33
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module mmio_sha2 #(
    parameter A_WIDTH = 8,
    parameter D_WIDTH = 32,
    parameter I_DEPTH = 32,
    parameter O_DEPTH = 2
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic               wr_en_i,
    input logic [A_WIDTH-1:0] wr_addr_i,
    input logic [D_WIDTH-1:0] wr_data_i,

    input  logic               rd_en_i,
    input  logic [A_WIDTH-1:0] rd_addr_i,
    output logic [D_WIDTH-1:0] rd_data_o,

    output logic intr_o
);

typedef enum {
    SHA2_REG_CTRL_0    = 'h0,
    SHA2_REG_CTRL_1    = 'h1,
    SHA2_REG_DATA_I_LO = 'h2,
    SHA2_REG_DATA_I_HI = 'h3,
    SHA2_REG_DATA_O_LO = 'h4,
    SHA2_REG_DATA_O_HI = 'h5,
    SHA2_REG_RSVD_0    = 'h6,
    SHA2_REG_RSVD_1    = 'h7,

    SHA2_REG_IDX_MAX
} sha2_reg_t;

typedef struct packed {
    logic        intr_done;
    logic        intr_next;
    logic [29:1] rsvd;
    logic        rst_n;
} sha2_ctrl_0_t;

typedef struct packed {
    logic        done;
    logic        next;
    logic [29:3] rsvd;
    logic  [2:1] mode;
    logic        last;
} sha2_ctrl_1_t;

typedef struct packed {
    logic [63:32] hi;
    logic [31: 0] lo;
} sha2_data_io_t;

logic [1:0] in_mode;
logic       in_last;

logic [63:0] in_data;
logic        in_valid;
logic        in_ready;

logic [63:0] out_data;
logic        out_valid;
logic        out_ready;

logic        intr_done_p;
logic        intr_next_p;

sha2_ctrl_0_t sha2_ctrl_0;
sha2_ctrl_1_t sha2_ctrl_1;

sha2_data_io_t sha2_data_i;
sha2_data_io_t sha2_data_o;

assign in_mode = sha2_ctrl_1.mode;
assign in_last = sha2_ctrl_1.last;

assign sha2_data_o = out_data;

logic [D_WIDTH-1:0] regs[SHA2_REG_IDX_MAX];

assign regs[SHA2_REG_CTRL_0]    = {sha2_ctrl_0.intr_done, sha2_ctrl_0.intr_next, 29'b0, sha2_ctrl_0.rst_n};
assign regs[SHA2_REG_CTRL_1]    = {sha2_ctrl_1.done, sha2_ctrl_1.next, 27'b0, sha2_ctrl_1.mode, sha2_ctrl_1.last};
assign regs[SHA2_REG_DATA_I_LO] = sha2_data_i.lo;
assign regs[SHA2_REG_DATA_I_HI] = sha2_data_i.hi;
assign regs[SHA2_REG_DATA_O_LO] = sha2_data_o.lo;
assign regs[SHA2_REG_DATA_O_HI] = sha2_data_o.hi;
assign regs[SHA2_REG_RSVD_0]    = 'b0;
assign regs[SHA2_REG_RSVD_1]    = 'b0;

assign intr_o = sha2_ctrl_0.intr_next | sha2_ctrl_0.intr_done;

edge2en intr_done_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(sha2_ctrl_1.done),
    .pos_edge_o(intr_done_p)
);

edge2en intr_next_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(sha2_ctrl_1.next),
    .pos_edge_o(intr_next_p)
);

sha2 #(
    .I_DEPTH(I_DEPTH),
    .O_DEPTH(O_DEPTH)
) sha2 (
    .clk_i(clk_i),
    .rst_n_i(sha2_ctrl_0.rst_n),

    .in_mode_i(in_mode),
    .in_last_i(in_last),

    .in_data_i(in_data),
    .in_valid_i(in_valid),
    .in_ready_o(in_ready),

    .out_data_o(out_data),
    .out_valid_o(out_valid),
    .out_ready_i(out_ready)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        in_data  <= 'b0;
        in_valid <= 'b0;
    end else begin
        in_data  <= wr_en_i & (wr_addr_i[4:2] == SHA2_REG_DATA_I_HI) ? sha2_data_i : in_data;
        in_valid <= wr_en_i & (wr_addr_i[4:2] == SHA2_REG_DATA_I_HI) ? 'b1 : (in_ready ? 'b0 : in_valid);
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        out_ready <= 'b0;
    end else begin
        out_ready <= out_valid & rd_en_i & (rd_addr_i[4:2] == SHA2_REG_DATA_O_HI);
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rd_data_o <= 'b0;

        sha2_ctrl_0 <= 'b0;
        sha2_ctrl_1 <= 'b0;

        sha2_data_i <= 'b0;
    end else begin
        rd_data_o <= rd_en_i ? regs[rd_addr_i[4:2]] : rd_data_o;

        if (wr_en_i) begin
            case (wr_addr_i[3:2])
                SHA2_REG_CTRL_0: begin
                    sha2_ctrl_0.rst_n <= wr_data_i[0];
                end
                SHA2_REG_CTRL_1: begin
                    sha2_ctrl_1.last <= wr_data_i[0];
                    sha2_ctrl_1.mode <= wr_data_i[2:1];
                end
                SHA2_REG_DATA_I_LO: sha2_data_i.lo <= wr_data_i;
                SHA2_REG_DATA_I_HI: sha2_data_i.hi <= wr_data_i;
                default;
            endcase
        end

        sha2_ctrl_0.intr_done <= intr_done_p ? 'b1 : (rd_en_i & (rd_addr_i[4:2] == SHA2_REG_CTRL_0) ? 'b0 : sha2_ctrl_0.intr_done);
        sha2_ctrl_0.intr_next <= intr_next_p ? 'b1 : (rd_en_i & (rd_addr_i[4:2] == SHA2_REG_CTRL_0) ? 'b0 : sha2_ctrl_0.intr_next);
    end
end

endmodule
