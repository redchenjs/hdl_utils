/*
 * sha256.sv
 *
 *  Created on: 2023-07-21 11:30
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module sha256 #(
    parameter D_WIDTH = 32,
    parameter I_WIDTH = 512,
    parameter O_WIDTH = 256
) (
    input logic clk_i,
    input logic rst_n_i,

    input  logic [I_WIDTH-1:0] in_data_i,
    input  logic               in_last_i,
    input  logic               in_valid_i,
    output logic               in_ready_o,

    output logic [O_WIDTH-1:0] out_data_o,
    output logic               out_valid_o
);

typedef enum logic [1:0] {
    IDLE = 'h0,
    INIT = 'h1,
    NEXT = 'h2,
    LOAD = 'h3
} state_t;

state_t ctl_sta;

logic [5:0] iter;
logic [6:0] iter_w;
logic       iter_next;
logic       iter_last;
logic       iter_done;

logic [D_WIDTH-1:0] a;
logic [D_WIDTH-1:0] b;
logic [D_WIDTH-1:0] c;
logic [D_WIDTH-1:0] d;
logic [D_WIDTH-1:0] e;
logic [D_WIDTH-1:0] f;
logic [D_WIDTH-1:0] g;
logic [D_WIDTH-1:0] h;

logic [15:0] [D_WIDTH-1:0] w;
logic        [D_WIDTH-1:0] wk;

wire [7:0] [D_WIDTH-1:0] n = {
    'h5be0_cd19,    // a
    'h1f83_d9ab,    // b
    'h9b05_688c,    // c
    'h510e_527f,    // d
    'ha54f_f53a,    // e
    'h3c6e_f372,    // f
    'hbb67_ae85,    // g
    'h6a09_e667     // h
};
wire [15:0] [D_WIDTH-1:0] m;
wire [63:0] [D_WIDTH-1:0] k = {
    'hc671_78f2, 'hbef9_a3f7, 'ha450_6ceb, 'h90be_fffa,
    'h8cc7_0208, 'h84c8_7814, 'h78a5_636f, 'h748f_82ee,
    'h682e_6ff3, 'h5b9c_ca4f, 'h4ed8_aa4a, 'h391c_0cb3,
    'h34b0_bcb5, 'h2748_774c, 'h1e37_6c08, 'h19a4_c116,
    'h106a_a070, 'hf40e_3585, 'hd699_0624, 'hd192_e819,
    'hc76c_51a3, 'hc24b_8b70, 'ha81a_664b, 'ha2bf_e8a1,
    'h9272_2c85, 'h81c2_c92e, 'h766a_0abb, 'h650a_7354,
    'h5338_0d13, 'h4d2c_6dfc, 'h2e1b_2138, 'h27b7_0a85,
    'h1429_2967, 'h06ca_6351, 'hd5a7_9147, 'hc6e0_0bf3,
    'hbf59_7fc7, 'hb003_27c8, 'ha831_c66d, 'h983e_5152,
    'h76f9_88da, 'h5cb0_a9dc, 'h4a74_84aa, 'h2de9_2c6f,
    'h240c_a1cc, 'h0fc1_9dc6, 'hefbe_4786, 'he49b_69c1,
    'hc19b_f174, 'h9bdc_06a7, 'h80de_b1fe, 'h72be_5d74,
    'h550c_7dc3, 'h2431_85be, 'h1283_5b01, 'hd807_aa98,
    'hab1c_5ed5, 'h923f_82a4, 'h59f1_11f1, 'h3956_c25b,
    'he9b5_dba5, 'hb5c0_fbcf, 'h7137_4491, 'h428a_2f98
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

generate
    genvar i;
    for (i = 0; i < 16; i++) begin: gen_m
        assign m[15-i] = in_data_i[D_WIDTH*(i+1)-1:D_WIDTH*i];
    end
endgenerate

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        in_ready_o <= 'b0;
    end else begin
        in_ready_o <= in_valid_i & (ctl_sta != LOAD) & iter_next;
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        out_data_o  <= 'b0;
        out_valid_o <= 'b0;
    end else begin
        out_data_o  <= iter_done ? {a, b, c, d, e, f, g, h} : out_data_o;
        out_valid_o <= iter_done;
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

        iter      <= 'b0;
        iter_w    <= 'b0;
        iter_next <= 'b0;
        iter_last <= 'b0;
        iter_done <= 'b0;
    end else begin
        case (ctl_sta)
            IDLE:
                ctl_sta <= in_valid_i ? INIT : ctl_sta;
            INIT:
                ctl_sta <= NEXT;
            NEXT:
                ctl_sta <= iter_next ? LOAD : ctl_sta;
            LOAD:
                ctl_sta <= iter_last ? IDLE : NEXT;
            default:
                ctl_sta <= IDLE;
        endcase

        case (ctl_sta)
            IDLE: begin
                a <= 'b0;
                b <= 'b0;
                c <= 'b0;
                d <= 'b0;
                e <= 'b0;
                f <= 'b0;
                g <= 'b0;
                h <= 'b0;

                w[0] <= m[0];

                iter   <= 'b0;
                iter_w <= 'b0;
            end
            INIT: begin
                a <= a + n[0];
                b <= b + n[1];
                c <= c + n[2];
                d <= d + n[3];
                e <= e + n[4];
                f <= f + n[5];
                g <= g + n[6];
                h <= h + n[7];

                w[0] <= m[1];
                wk   <= k[0] + w[0];

                iter   <= 'b0;
                iter_w <= 'd2;
            end
            NEXT: begin
                a <= t_1 + t_2;
                b <= a;
                c <= b;
                d <= c;
                e <= d + t_1;
                f <= e;
                g <= f;
                h <= g;

                if (iter_w <= 15) begin
                    w[0] <= m[iter_w];

                    iter_w <= iter_w + 'b1;
                end else if (iter_w <= 63) begin
                    w[0] <= sigma_1 + w[6] + sigma_0 + w[15];

                    iter_w <= iter_w + 'b1;
                end

                wk <= k[iter_w-1] + w[0];

                iter <= iter + 'b1;
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

                w  <= 'b0;
                wk <= 'b0;

                iter   <= 'b0;
                iter_w <= 'b0;
            end
        endcase

        for (int i = 1; i < 16; i++) begin
            w[i] <= w[i-1];
        end

        iter_next <= (iter == 'd62);
        iter_last <= (in_valid_i & in_last_i) ? 'b1 : (ctl_sta == LOAD) ? 'b0 : iter_last;
        iter_done <= (ctl_sta == LOAD);
    end
end

endmodule
