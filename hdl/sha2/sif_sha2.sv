/*
 * sif_sha2.sv
 *
 *  Created on: 2023-07-21 11:30
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module sif_sha2(
    stream_if.slave  s_sif,
    stream_if.master m_sif
);

parameter C_WIDTH = 2;
parameter I_WIDTH = 64;
parameter O_WIDTH = 512;

parameter D_WIDTH = 64;
parameter I_COUNT = 16;
parameter O_COUNT = 8;

typedef enum {
    SHA_224 = 'h0,
    SHA_256 = 'h1,
    SHA_384 = 'h2,
    SHA_512 = 'h3
} mode_t;

typedef enum {
    IDLE = 'h0,
    INIT = 'h1,
    NEXT = 'h2,
    LOAD = 'h3,
    LAST = 'h4,
    WAIT = 'h5
} state_t;

state_t ctl_sta;

logic [7:0] iter_cnt;
logic [7:0] iter_max;

logic       iter_save;
logic       iter_keep;
logic       iter_idle;

logic       iter_load;
logic       iter_next;

logic [1:0] iter_mode;
logic       iter_last;

logic [D_WIDTH-1:0] a;
logic [D_WIDTH-1:0] b;
logic [D_WIDTH-1:0] c;
logic [D_WIDTH-1:0] d;
logic [D_WIDTH-1:0] e;
logic [D_WIDTH-1:0] f;
logic [D_WIDTH-1:0] g;
logic [D_WIDTH-1:0] h;

logic [223:0] out_data_224;
logic [255:0] out_data_256;
logic [383:0] out_data_384;
logic [511:0] out_data_512;

logic [D_WIDTH-1:0] sigma_0;
logic [D_WIDTH-1:0] sigma_1;

logic [D_WIDTH-1:0] big_sigma_0;
logic [D_WIDTH-1:0] big_sigma_1;

logic               [D_WIDTH-1:0] m;
logic [I_COUNT-1:0] [D_WIDTH-1:0] w;
logic [O_COUNT-1:0] [D_WIDTH-1:0] s;

wire [7:0] [63:0] n_384 = {
    64'h47b5_481d_befa_4fa4,    // h
    64'hdb0c_2e0d_64f9_8fa7,    // g
    64'h8eb4_4a87_6858_1511,    // f
    64'h6733_2667_ffc0_0b31,    // e
    64'h152f_ecd8_f70e_5939,    // d
    64'h9159_015a_3070_dd17,    // c
    64'h629a_292a_367c_d507,    // b
    64'hcbbb_9d5d_c105_9ed8     // a
};
wire [7:0] [63:0] n_512 = {
    64'h5be0_cd19_137e_2179,    // h
    64'h1f83_d9ab_fb41_bd6b,    // g
    64'h9b05_688c_2b3e_6c1f,    // f
    64'h510e_527f_ade6_82d1,    // e
    64'ha54f_f53a_5f1d_36f1,    // d
    64'h3c6e_f372_fe94_f82b,    // c
    64'hbb67_ae85_84ca_a73b,    // b
    64'h6a09_e667_f3bc_c908     // a
};
wire [79:0] [63:0] k = {
    64'h6c44_198c_4a47_5817, 64'h5fcb_6fab_3ad6_faec, 64'h597f_299c_fc65_7e2a, 64'h4cc5_d4be_cb3e_42b6,
    64'h431d_67c4_9c10_0d4c, 64'h3c9e_be0a_15c9_bebc, 64'h32ca_ab7b_40c7_2493, 64'h28db_77f5_2304_7d84,
    64'h1b71_0b35_131c_471b, 64'h113f_9804_bef9_0dae, 64'h0a63_7dc5_a2c8_98a6, 64'h06f0_67aa_7217_6fba,
    64'hf57d_4f7f_ee6e_d178, 64'heada_7dd6_cde0_eb1e, 64'hd186_b8c7_21c0_c207, 64'hca27_3ece_ea26_619c,
    64'hc671_78f2_e372_532b, 64'hbef9_a3f7_b2c6_7915, 64'ha450_6ceb_de82_bde9, 64'h90be_fffa_2363_1e28,
    64'h8cc7_0208_1a64_39ec, 64'h84c8_7814_a1f0_ab72, 64'h78a5_636f_4317_2f60, 64'h748f_82ee_5def_b2fc,
    64'h682e_6ff3_d6b2_b8a3, 64'h5b9c_ca4f_7763_e373, 64'h4ed8_aa4a_e341_8acb, 64'h391c_0cb3_c5c9_5a63,
    64'h34b0_bcb5_e19b_48a8, 64'h2748_774c_df8e_eb99, 64'h1e37_6c08_5141_ab53, 64'h19a4_c116_b8d2_d0c8,
    64'h106a_a070_32bb_d1b8, 64'hf40e_3585_5771_202a, 64'hd699_0624_5565_a910, 64'hd192_e819_d6ef_5218,
    64'hc76c_51a3_0654_be30, 64'hc24b_8b70_d0f8_9791, 64'ha81a_664b_bc42_3001, 64'ha2bf_e8a1_4cf1_0364,
    64'h9272_2c85_1482_353b, 64'h81c2_c92e_47ed_aee6, 64'h766a_0abb_3c77_b2a8, 64'h650a_7354_8baf_63de,
    64'h5338_0d13_9d95_b3df, 64'h4d2c_6dfc_5ac4_2aed, 64'h2e1b_2138_5c26_c926, 64'h27b7_0a85_46d2_2ffc,
    64'h1429_2967_0a0e_6e70, 64'h06ca_6351_e003_826f, 64'hd5a7_9147_930a_a725, 64'hc6e0_0bf3_3da8_8fc2,
    64'hbf59_7fc7_beef_0ee4, 64'hb003_27c8_98fb_213f, 64'ha831_c66d_2db4_3210, 64'h983e_5152_ee66_dfab,
    64'h76f9_88da_8311_53b5, 64'h5cb0_a9dc_bd41_fbd4, 64'h4a74_84aa_6ea6_e483, 64'h2de9_2c6f_592b_0275,
    64'h240c_a1cc_77ac_9c65, 64'h0fc1_9dc6_8b8c_d5b5, 64'hefbe_4786_384f_25e3, 64'he49b_69c1_9ef1_4ad2,
    64'hc19b_f174_cf69_2694, 64'h9bdc_06a7_25c7_1235, 64'h80de_b1fe_3b16_96b1, 64'h72be_5d74_f27b_896f,
    64'h550c_7dc3_d5ff_b4e2, 64'h2431_85be_4ee4_b28c, 64'h1283_5b01_4570_6fbe, 64'hd807_aa98_a303_0242,
    64'hab1c_5ed5_da6d_8118, 64'h923f_82a4_af19_4f9b, 64'h59f1_11f1_b605_d019, 64'h3956_c25b_f348_b538,
    64'he9b5_dba5_8189_dbbc, 64'hb5c0_fbcf_ec4d_3b2f, 64'h7137_4491_23ef_65cd, 64'h428a_2f98_d728_ae22
};

wire [D_WIDTH-1:0] x = w[14];
wire [D_WIDTH-1:0] y = w[ 1];

wire [D_WIDTH-1:0] ch  = (e & f) ^ (~e & g);
wire [D_WIDTH-1:0] mag = (a & b) ^ ( a & c) ^ (b & c);

wire [D_WIDTH-1:0] t_1 = big_sigma_1 + ch + h + m;
wire [D_WIDTH-1:0] t_2 = big_sigma_0 + mag;

wire               [D_WIDTH-1:0] data_i = {<< byte{s_sif.data}};
wire [O_COUNT-1:0] [D_WIDTH-1:0] data_o = {h, g, f, e, d, c, b, a};

generate
    genvar i;

    for (i = 0; i < 7; i++) begin: gen_data_224
        assign out_data_224[i*32+:32] = data_o[6-i];
    end

    for (i = 0; i < 8; i++) begin: gen_data_256
        assign out_data_256[i*32+:32] = data_o[7-i];
    end

    for (i = 0; i < 6; i++) begin: gen_data_384
        assign out_data_384[i*64+:64] = data_o[5-i];
    end

    for (i = 0; i < 8; i++) begin: gen_data_512
        assign out_data_512[i*64+:64] = data_o[7-i];
    end
endgenerate

always_comb begin
    if (iter_mode[1]) begin
        sigma_0 = {x[ 0:0], x[63: 1]} ^ {x[ 7:0], x[63: 8]} ^ {7'b0, x[63: 7]};
        sigma_1 = {y[18:0], y[63:19]} ^ {y[60:0], y[63:61]} ^ {6'b0, y[63: 6]};

        big_sigma_0 = {a[27:0], a[63:28]} ^ {a[33:0], a[63:34]} ^ {a[38:0], a[63:39]};
        big_sigma_1 = {e[13:0], e[63:14]} ^ {e[17:0], e[63:18]} ^ {e[40:0], e[63:41]};
    end else begin
        sigma_0 = {x[ 6:0], x[31: 7]} ^ {x[17:0], x[31:18]} ^ { 3'b0, x[31: 3]};
        sigma_1 = {y[16:0], y[31:17]} ^ {y[18:0], y[31:19]} ^ {10'b0, y[31:10]};

        big_sigma_0 = {a[1:0], a[31:2]} ^ {a[12:0], a[31:13]} ^ {a[21:0], a[31:22]};
        big_sigma_1 = {e[5:0], e[31:6]} ^ {e[10:0], e[31:11]} ^ {e[24:0], e[31:25]};
    end
end

always_ff @(posedge s_sif.clk or negedge s_sif.rst_n)
begin
    if (!s_sif.rst_n) begin
        s_sif.ready <= 'b1;
    end else begin
        if (iter_last) begin
            s_sif.ready <= (ctl_sta == LAST) ? 'b1 : (iter_cnt >= 12) & iter_keep ? 'b0 : s_sif.ready;
        end else begin
            s_sif.ready <= (ctl_sta == LOAD) ? 'b1 : (iter_cnt >= 12) ? 'b0 : s_sif.ready;
        end
    end
end

assign m_sif.clk   = s_sif.clk;
assign m_sif.rst_n = s_sif.rst_n;

always_ff @(posedge s_sif.clk or negedge s_sif.rst_n)
begin
    if (!s_sif.rst_n) begin
        m_sif.data  <= 'b0;
        m_sif.valid <= 'b0;
    end else begin
        if (~m_sif.valid & (ctl_sta == LAST)) begin
            case (iter_mode)
                SHA_224: m_sif.data <= out_data_224;
                SHA_256: m_sif.data <= out_data_256;
                SHA_384: m_sif.data <= out_data_384;
                SHA_512: m_sif.data <= out_data_512;
            endcase

            m_sif.valid <= 'b1;
        end else begin
            m_sif.data  <= m_sif.ready ? 'b0 : m_sif.data;
            m_sif.valid <= m_sif.ready ? 'b0 : m_sif.valid;
        end
    end
end

always_ff @(posedge s_sif.clk or negedge s_sif.rst_n)
begin
    if (!s_sif.rst_n) begin
        ctl_sta <= IDLE;

        a <= 'b0;
        b <= 'b0;
        c <= 'b0;
        d <= 'b0;
        e <= 'b0;
        f <= 'b0;
        g <= 'b0;
        h <= 'b0;

        m <= 'b0;
        w <= 'b0;
        s <= 'b0;

        iter_cnt <= 'b0;
        iter_max <= 'b0;

        iter_save <= 'b0;
        iter_keep <= 'b0;
        iter_idle <= 'b0;

        iter_load <= 'b0;
        iter_next <= 'b0;

        iter_mode <= 'b0;
        iter_last <= 'b0;
    end else begin
        case (ctl_sta)
            IDLE, LAST:
                ctl_sta <= s_sif.valid ? INIT : IDLE;
            WAIT:
                ctl_sta <= s_sif.valid ? INIT : WAIT;
            INIT:
                ctl_sta <= s_sif.valid ? NEXT : INIT;
            NEXT:
                ctl_sta <= iter_next ? LOAD : NEXT;
            LOAD:
                ctl_sta <= iter_last ? LAST : WAIT;
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

                m <= 'b0;

                for (int i = 0; i < 8; i++) begin
                    case (s_sif.ctrl[C_WIDTH-1:0])
                        SHA_224: s[i] <= s_sif.valid & iter_idle ? n_384[i][31: 0] : s[i];
                        SHA_256: s[i] <= s_sif.valid & iter_idle ? n_512[i][63:32] : s[i];
                        SHA_384: s[i] <= s_sif.valid & iter_idle ? n_384[i]        : s[i];
                        SHA_512: s[i] <= s_sif.valid & iter_idle ? n_512[i]        : s[i];
                    endcase
                end

                w[0] <= data_i;

                iter_cnt <= 'b0;
                iter_max <= 'b0;
            end
            INIT: begin
                if (s_sif.valid) begin
                    a <= a + s[0];
                    b <= b + s[1];
                    c <= c + s[2];
                    d <= d + s[3];
                    e <= e + s[4];
                    f <= f + s[5];
                    g <= g + s[6];
                    h <= h + s[7];

                    s <= s;

                    case (iter_mode)
                        SHA_224: m[31:0] <= k[0][63:32] + w[0];
                        SHA_256: m[31:0] <= k[0][63:32] + w[0];
                        SHA_384: m       <= k[0]        + w[0];
                        SHA_512: m       <= k[0]        + w[0];
                    endcase

                    w[0] <= data_i;
                    w[1] <= w[0];

                    iter_cnt <= 'b0;
                    iter_max <= iter_mode[1] ? 'd79 : 'd63;
                end
            end
            LOAD: begin
                a <= a + s[0];
                b <= b + s[1];
                c <= c + s[2];
                d <= d + s[3];
                e <= e + s[4];
                f <= f + s[5];
                g <= g + s[6];
                h <= h + s[7];

                s <= s;

                case (iter_mode)
                    SHA_224: m[31:0] <= k[0][63:32] + w[0];
                    SHA_256: m[31:0] <= k[0][63:32] + w[0];
                    SHA_384: m       <= k[0]        + w[0];
                    SHA_512: m       <= k[0]        + w[0];
                endcase

                w[0] <= data_i;
                w[1] <= w[0];

                iter_cnt <= 'b0;
                iter_max <= iter_mode[1] ? 'd79 : 'd63;
            end
            NEXT: begin
                if ((iter_cnt + 2) <= 15) begin
                    if (s_sif.valid) begin
                        a <= t_1 + t_2;
                        b <= a;
                        c <= b;
                        d <= c;
                        e <= t_1 + d;
                        f <= e;
                        g <= f;
                        h <= g;

                        case (iter_mode)
                            SHA_224: m[31:0] <= k[iter_cnt + 1][63:32] + w[0];
                            SHA_256: m[31:0] <= k[iter_cnt + 1][63:32] + w[0];
                            SHA_384: m       <= k[iter_cnt + 1]        + w[0];
                            SHA_512: m       <= k[iter_cnt + 1]        + w[0];
                        endcase

                        for (int i = 0; i < 8; i++) begin
                            s[i] <= iter_save ? data_o[i] : s[i];
                        end

                        w[0] <= data_i;

                        for (int i = 1; i < 16; i++) begin
                            w[i] <= w[i-1];
                        end

                        iter_cnt <= iter_cnt + 'b1;
                    end
                end else begin
                    a <= t_1 + t_2;
                    b <= a;
                    c <= b;
                    d <= c;
                    e <= t_1 + d;
                    f <= e;
                    g <= f;
                    h <= g;

                    case (iter_mode)
                        SHA_224: m[31:0] <= k[iter_cnt + 1][63:32] + w[0];
                        SHA_256: m[31:0] <= k[iter_cnt + 1][63:32] + w[0];
                        SHA_384: m       <= k[iter_cnt + 1]        + w[0];
                        SHA_512: m       <= k[iter_cnt + 1]        + w[0];
                    endcase

                    for (int i = 0; i < 8; i++) begin
                        s[i] <= iter_save ? data_o[i] : s[i];
                    end

                    w[0] <= sigma_1 + w[6] + sigma_0 + w[15];

                    for (int i = 1; i < 16; i++) begin
                        w[i] <= w[i-1];
                    end

                    iter_cnt <= iter_cnt + 'b1;
                end

                iter_max <= iter_max;
            end
            WAIT: begin
                if (s_sif.valid) begin
                    a <= 'b0;
                    b <= 'b0;
                    c <= 'b0;
                    d <= 'b0;
                    e <= 'b0;
                    f <= 'b0;
                    g <= 'b0;
                    h <= 'b0;

                    m <= 'b0;

                    for (int i = 0; i < 8; i++) begin
                        s[i] <= data_o[i];
                    end
                end else begin
                    a <= a;
                    b <= b;
                    c <= c;
                    d <= d;
                    e <= e;
                    f <= f;
                    g <= g;
                    h <= h;

                    m <= m;
                    s <= s;
                end

                w[0] <= data_i;

                iter_cnt <= iter_cnt;
                iter_max <= iter_max;
            end
        endcase

        iter_save <= (ctl_sta == INIT) | (ctl_sta == LOAD);
        iter_keep <= (ctl_sta == INIT) | (ctl_sta == LOAD) ? 'b1 : (iter_load ? 'b0 : iter_keep);
        iter_idle <= (ctl_sta == IDLE) | (ctl_sta == LAST) ? (s_sif.valid ? 'b0 : 'b1) : iter_idle;

        iter_load <= (iter_cnt == (iter_max - 3));
        iter_next <= (iter_cnt == (iter_max - 1));

        iter_mode <= s_sif.valid & iter_idle ? s_sif.ctrl[C_WIDTH-1:0] : (ctl_sta == LAST) ? 'b0 : iter_mode;
        iter_last <= s_sif.valid & (iter_cnt == 'd13) ? s_sif.last : (ctl_sta == LAST) ? 'b0 : iter_last;
    end
end

endmodule
