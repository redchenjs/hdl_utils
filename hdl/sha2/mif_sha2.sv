/*
 * mif_sha2.sv
 *
 *  Created on: 2023-08-09 11:33
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module mif_sha2 #(
    parameter A_WIDTH = 8,
    parameter D_WIDTH = 32,
    parameter I_DEPTH = 32,
    parameter O_DEPTH = 2
) (
    memory_if.slave s_mif,
    output    logic s_irq
);

parameter C_WIDTH = 2;
parameter I_WIDTH = 64;
parameter O_WIDTH = 512;

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
    logic [28:0] rsvd;
    logic        rst_n;
} sha2_ctrl_0_t;

typedef struct packed {
    logic        done;
    logic        next;
    logic [25:0] rsvd;
    logic        read;
    logic  [1:0] mode;
    logic        last;
} sha2_ctrl_1_t;

typedef struct packed {
    logic [31:0] lo;
    logic [31:0] hi;
} sha2_data_i_t;

typedef struct packed {
    logic [31:0] hi;
    logic [31:0] lo;
} sha2_data_o_t;

logic in_valid;

logic out_ready;
logic out_valid_r;

logic intr_done_p;
logic intr_next_p;

logic out_fifo_full;
logic out_fifo_empty;

sha2_ctrl_0_t sha2_ctrl_0;
sha2_ctrl_1_t sha2_ctrl_1;

sha2_data_i_t sha2_data_i;
sha2_data_o_t sha2_data_o;

assign sha2_ctrl_1.rsvd = 'b0;
assign sha2_ctrl_1.next = s_sif.ready;
assign sha2_ctrl_1.done = ~out_fifo_empty;

logic [D_WIDTH-1:0] regs[SHA2_REG_IDX_MAX];

assign regs[SHA2_REG_CTRL_0]    = {sha2_ctrl_0.intr_done, sha2_ctrl_0.intr_next, 29'b0, sha2_ctrl_0.rst_n};
assign regs[SHA2_REG_CTRL_1]    = {sha2_ctrl_1.done, sha2_ctrl_1.next, 27'b0, sha2_ctrl_1.mode, sha2_ctrl_1.last};
assign regs[SHA2_REG_DATA_I_LO] = sha2_data_i.lo;
assign regs[SHA2_REG_DATA_I_HI] = sha2_data_i.hi;
assign regs[SHA2_REG_DATA_O_LO] = sha2_data_o.lo;
assign regs[SHA2_REG_DATA_O_HI] = sha2_data_o.hi;
assign regs[SHA2_REG_RSVD_0]    = 'b0;
assign regs[SHA2_REG_RSVD_1]    = 'b0;

assign s_irq = sha2_ctrl_0.intr_done | sha2_ctrl_0.intr_next;

edge2en intr_done_en(
    .clk_i(s_mif.clk),
    .rst_n_i(s_mif.rst_n),
    .data_i(sha2_ctrl_1.done),
    .pos_edge_o(intr_done_p)
);

edge2en intr_next_en(
    .clk_i(s_mif.clk),
    .rst_n_i(s_mif.rst_n),
    .data_i(sha2_ctrl_1.next),
    .pos_edge_o(intr_next_p)
);

stream_if #(
    .CTRL_WIDTH(C_WIDTH),
    .DATA_WIDTH(I_WIDTH)
) s_sif();

stream_if #(
    .CTRL_WIDTH(C_WIDTH),
    .DATA_WIDTH(O_WIDTH)
) m_sif();

assign s_sif.clk   = s_mif.clk;
assign s_sif.rst_n = s_mif.rst_n;
assign s_sif.valid = in_valid;
assign s_sif.ctrl  = sha2_ctrl_1.mode;
assign s_sif.data  = sha2_data_i;
assign s_sif.last  = sha2_ctrl_1.last;

assign m_sif.ready = ~out_fifo_full;

// s_sif (64-bit) => m_sif (512-bit)
sif_sha2 sif_sha2(
    .s_sif(s_sif),
    .m_sif(m_sif)
);

// m_sif (512-bit) => sha2_data_o (64-bit)
fifo #(
    .I_WIDTH(512),
    .I_DEPTH(O_DEPTH),
    .O_WIDTH(64),
    .O_DEPTH(O_DEPTH*8)
) fifo_out (
    .clk_i(s_mif.clk),
    .rst_n_i(sha2_ctrl_0.rst_n),

    .wr_en_i(m_sif.valid),
    .wr_data_i(m_sif.data),
    .wr_full_o(out_fifo_full),
    .wr_free_o(),

    .rd_en_i(out_ready),
    .rd_data_o(sha2_data_o),
    .rd_empty_o(out_fifo_empty),
    .rd_avail_o()
);

always_ff @(posedge s_mif.clk or negedge s_mif.rst_n)
begin
    if (!s_mif.rst_n) begin
        in_valid <= 'b0;
    end else begin
        in_valid <= s_mif.wr_en & (s_mif.wr_addr[4:2] == SHA2_REG_DATA_I_HI);
    end
end

always_ff @(posedge s_mif.clk or negedge s_mif.rst_n)
begin
    if (!s_mif.rst_n) begin
        out_ready   <= 'b0;
        out_valid_r <= 'b0;
    end else begin
        out_ready   <= ~out_fifo_empty & sha2_ctrl_1.read;
        out_valid_r <= ~out_fifo_empty;
    end
end

always_ff @(posedge s_mif.clk or negedge s_mif.rst_n)
begin
    if (!s_mif.rst_n) begin
        s_mif.rd_data <= 'b0;

        sha2_ctrl_0 <= 'b0;

        sha2_ctrl_1.last <= 'b0;
        sha2_ctrl_1.mode <= 'b0;
        sha2_ctrl_1.read <= 'b0;

        sha2_data_i <= 'b0;
    end else begin
        s_mif.rd_data <= s_mif.rd_en ? regs[s_mif.rd_addr[4:2]] : s_mif.rd_data;

        if (s_mif.wr_en) begin
            case (s_mif.wr_addr[3:2])
                SHA2_REG_CTRL_0: begin
                    sha2_ctrl_0.rst_n <= s_mif.wr_data[0];
                end
                SHA2_REG_CTRL_1: begin
                    sha2_ctrl_1.last <= s_mif.wr_data[0];
                    sha2_ctrl_1.mode <= s_mif.wr_data[2:1];
                    sha2_ctrl_1.read <= s_mif.wr_data[3];
                end
                SHA2_REG_DATA_I_LO: sha2_data_i.lo <= s_mif.wr_data;
                SHA2_REG_DATA_I_HI: sha2_data_i.hi <= s_mif.wr_data;
                default: begin
                    sha2_ctrl_1.read <= 'b0;
                end
            endcase
        end else begin
            sha2_ctrl_1.read <= 'b0;
        end

        sha2_ctrl_0.intr_done <= intr_done_p ? 'b1 : (s_mif.rd_en & (s_mif.rd_addr[4:2] == SHA2_REG_CTRL_0) ? 'b0 : sha2_ctrl_0.intr_done);
        sha2_ctrl_0.intr_next <= intr_next_p ? 'b1 : (s_mif.rd_en & (s_mif.rd_addr[4:2] == SHA2_REG_CTRL_0) ? 'b0 : sha2_ctrl_0.intr_next);
    end
end

endmodule
