/*
 * sha256.sv
 *
 *  Created on: 2023-07-21 11:30
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

parameter I_COUNT = 16;
parameter D_ITERS = 64;
parameter D_WIDTH = 32;
parameter O_COUNT = 8;

module sha256(
    input logic clk_i,
    input logic rst_n_i,

    input  logic [D_WIDTH-1:0] in_data_i,
    input  logic               in_last_i,
    input  logic               in_valid_i,
    output logic               in_ready_o,

    output logic [D_WIDTH-1:0] out_data_o,
    output logic               out_valid_o,
    input  logic               out_ready_i
);

typedef enum logic [1:0] {
    IDLE = 'h0,
    LOAD = 'h1,
    NEXT = 'h2,
    LAST = 'h3
} state_t;

state_t ctl_sta;

logic [D_WIDTH-1:0] a;
logic [D_WIDTH-1:0] b;
logic [D_WIDTH-1:0] c;
logic [D_WIDTH-1:0] d;
logic [D_WIDTH-1:0] e;
logic [D_WIDTH-1:0] f;
logic [D_WIDTH-1:0] g;
logic [D_WIDTH-1:0] h;

logic [I_COUNT-1:0] [D_WIDTH-1:0] w;
logic               [D_WIDTH-1:0] wk;

logic       [$clog2(O_COUNT)-1:0] dout_cnt;
logic [O_COUNT-1:0] [D_WIDTH-1:0] dout_data;

logic                             dout_next;
logic                             dout_done;
logic                             dout_keep;

logic       [$clog2(D_ITERS)-1:0] iter_cnt;

logic                             iter_next;
logic                             iter_done;
logic                             iter_last;

wire [O_COUNT-1:0] [D_WIDTH-1:0] n = {
    32'h5be0_cd19,    // h
    32'h1f83_d9ab,    // g
    32'h9b05_688c,    // f
    32'h510e_527f,    // e
    32'ha54f_f53a,    // d
    32'h3c6e_f372,    // c
    32'hbb67_ae85,    // b
    32'h6a09_e667     // a
};
wire [D_ITERS-1:0] [D_WIDTH-1:0] k = {
    32'hc671_78f2, 32'hbef9_a3f7, 32'ha450_6ceb, 32'h90be_fffa,
    32'h8cc7_0208, 32'h84c8_7814, 32'h78a5_636f, 32'h748f_82ee,
    32'h682e_6ff3, 32'h5b9c_ca4f, 32'h4ed8_aa4a, 32'h391c_0cb3,
    32'h34b0_bcb5, 32'h2748_774c, 32'h1e37_6c08, 32'h19a4_c116,
    32'h106a_a070, 32'hf40e_3585, 32'hd699_0624, 32'hd192_e819,
    32'hc76c_51a3, 32'hc24b_8b70, 32'ha81a_664b, 32'ha2bf_e8a1,
    32'h9272_2c85, 32'h81c2_c92e, 32'h766a_0abb, 32'h650a_7354,
    32'h5338_0d13, 32'h4d2c_6dfc, 32'h2e1b_2138, 32'h27b7_0a85,
    32'h1429_2967, 32'h06ca_6351, 32'hd5a7_9147, 32'hc6e0_0bf3,
    32'hbf59_7fc7, 32'hb003_27c8, 32'ha831_c66d, 32'h983e_5152,
    32'h76f9_88da, 32'h5cb0_a9dc, 32'h4a74_84aa, 32'h2de9_2c6f,
    32'h240c_a1cc, 32'h0fc1_9dc6, 32'hefbe_4786, 32'he49b_69c1,
    32'hc19b_f174, 32'h9bdc_06a7, 32'h80de_b1fe, 32'h72be_5d74,
    32'h550c_7dc3, 32'h2431_85be, 32'h1283_5b01, 32'hd807_aa98,
    32'hab1c_5ed5, 32'h923f_82a4, 32'h59f1_11f1, 32'h3956_c25b,
    32'he9b5_dba5, 32'hb5c0_fbcf, 32'h7137_4491, 32'h428a_2f98
};

wire [D_WIDTH-1:0] x = w[14];
wire [D_WIDTH-1:0] y = w[ 1];

wire [D_WIDTH-1:0] ch  = (e & f) ^ (~e & g);
wire [D_WIDTH-1:0] mag = (a & b) ^ ( a & c) ^ (b & c);

wire [D_WIDTH-1:0] t_1 = big_sigma_1 + ch + h + wk;
wire [D_WIDTH-1:0] t_2 = big_sigma_0 + mag;

wire [D_WIDTH-1:0] sigma_0 = {x[ 6:0], x[31: 7]} ^ {x[17:0], x[31:18]} ^ { 3'b0, x[31: 3]};
wire [D_WIDTH-1:0] sigma_1 = {y[16:0], y[31:17]} ^ {y[18:0], y[31:19]} ^ {10'b0, y[31:10]};

wire [D_WIDTH-1:0] big_sigma_0 = {a[1:0], a[31:2]} ^ {a[12:0], a[31:13]} ^ {a[21:0], a[31:22]};
wire [D_WIDTH-1:0] big_sigma_1 = {e[5:0], e[31:6]} ^ {e[10:0], e[31:11]} ^ {e[24:0], e[31:25]};

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        in_ready_o <= 'b1;
    end else begin
        in_ready_o <= (ctl_sta == NEXT) & iter_next & iter_last ? 'b1 : ((ctl_sta == NEXT) & (iter_cnt >= 12) ? 'b0 : in_ready_o);
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        dout_cnt  <= 'b0;
        dout_data <= 'b0;

        dout_next <= 'b0;
        dout_done <= 'b0;
        dout_keep <= 'b0;

        out_data_o  <= 'b0;
        out_valid_o <= 'b0;
    end else begin
        dout_cnt  <= dout_done ? 'b0 : (dout_keep & out_ready_i ? dout_cnt + 'b1 : dout_cnt);
        dout_data <= dout_next ? {a, b, c, d, e, f, g, h} : dout_data;

        dout_next <= iter_done;
        dout_done <= (dout_cnt == 'd6) ? 'b1 : (dout_next ? 'b0 : dout_done);
        dout_keep <= dout_next & ~dout_done ? 'b1 : (dout_done ? 'b0 : dout_keep);

        out_data_o  <= dout_data[dout_cnt];
        out_valid_o <= dout_keep;
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        a <= 'b0;
        b <= 'b0;
        c <= 'b0;
        d <= 'b0;
        e <= 'b0;
        f <= 'b0;
        g <= 'b0;
        h <= 'b0;

        w  <= 'b0;
        wk <= 'b0;

        ctl_sta <= IDLE;

        iter_cnt  <= 'b0;
        iter_next <= 'b0;
        iter_done <= 'b0;
        iter_last <= 'b0;
    end else begin
        case (ctl_sta)
            IDLE, LAST:
                ctl_sta <= in_valid_i ? LOAD : IDLE;
            LOAD:
                ctl_sta <= iter_last ? LAST : NEXT;
            NEXT:
                ctl_sta <= iter_next ? LOAD : NEXT;
            default:
                ctl_sta <= IDLE;
        endcase

        case (ctl_sta)
            IDLE, LAST: begin
                a <= 'b0;
                b <= 'b0;
                c <= 'b0;
                d <= 'b0;
                e <= 'b0;
                f <= 'b0;
                g <= 'b0;
                h <= 'b0;

                wk   <= 'b0;
                w[0] <= in_data_i;

                iter_cnt <= 'b0;
            end
            LOAD: begin
                a <= a + n[0];
                b <= b + n[1];
                c <= c + n[2];
                d <= d + n[3];
                e <= e + n[4];
                f <= f + n[5];
                g <= g + n[6];
                h <= h + n[7];

                wk   <= k[0] + w[0];
                w[0] <= in_data_i;
                w[1] <= w[0];

                iter_cnt <= 'b0;
            end
            NEXT: begin
                a <= t_1 + t_2;
                b <= a;
                c <= b;
                d <= c;
                e <= t_1 + d;
                f <= e;
                g <= f;
                h <= g;

                wk <= k[iter_cnt + 1] + w[0];

                if ((iter_cnt + 2) <= 15) begin
                    w[0] <= in_valid_i ? in_data_i : w[0];

                    for (int i = 1; i < 16; i++) begin
                        w[i] <= in_valid_i ? w[i-1] : w[i];
                    end

                    iter_cnt <= in_valid_i ? iter_cnt + 'b1 : iter_cnt;
                end else begin
                    w[0] <= sigma_1 + w[6] + sigma_0 + w[15];

                    for (int i = 1; i < 16; i++) begin
                        w[i] <= w[i-1];
                    end

                    iter_cnt <= iter_cnt + 'b1;
                end

            end
        endcase

        iter_next <= (iter_cnt == 'd62);
        iter_done <= (iter_cnt == 'd63);
        iter_last <= ((ctl_sta == LOAD) & in_last_i) ? 'b1 : (ctl_sta == LAST) ? 'b0 : iter_last;
    end
end

endmodule
