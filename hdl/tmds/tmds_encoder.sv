/*
 * tmds_encoder.sv
 *
 *  Created on: 2023-11-10 01:15
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module tmds_encoder(
    input logic clk_i,
    input logic rst_n_i,

    input logic de_i,
    input logic c1_i,
    input logic c0_i,

    input  logic [7:0] d_i,
    output logic [9:0] q_o
);

// count 1s in a byte
function logic [3:0] N_1(
    input logic [7:0] x
);
    logic [1:0] x_0[4];
    logic [2:0] x_1[2];

    x_0[0] = x[0] + x[1];
    x_0[1] = x[2] + x[3];
    x_0[2] = x[4] + x[5];
    x_0[3] = x[6] + x[7];

    x_1[0]= x_0[0] + x_0[1];
    x_1[1]= x_0[2] + x_0[3];

    return x_1[0] + x_1[1];
endfunction

logic        [3:0] n_0;
logic        [3:0] n_1;

logic signed [4:0] m_0;
logic signed [4:0] m_1;

logic signed [4:0] c_t;
logic signed [4:0] c_n;

logic        [8:0] q_m;
logic        [9:0] q_n;

always_comb begin
    if ((N_1(d_i) > 4) | ((N_1(d_i) == 4) & ~d_i[0])) begin
        q_m[0] = d_i[0];
        q_m[1] = d_i[1] ^~ q_m[0];
        q_m[2] = d_i[2] ^~ q_m[1];
        q_m[3] = d_i[3] ^~ q_m[2];
        q_m[4] = d_i[4] ^~ q_m[3];
        q_m[5] = d_i[5] ^~ q_m[4];
        q_m[6] = d_i[6] ^~ q_m[5];
        q_m[7] = d_i[7] ^~ q_m[6];
        q_m[8] = 1'b0;
    end else begin
        q_m[0] = d_i[0];
        q_m[1] = d_i[1] ^ q_m[0];
        q_m[2] = d_i[2] ^ q_m[1];
        q_m[3] = d_i[3] ^ q_m[2];
        q_m[4] = d_i[4] ^ q_m[3];
        q_m[5] = d_i[5] ^ q_m[4];
        q_m[6] = d_i[6] ^ q_m[5];
        q_m[7] = d_i[7] ^ q_m[6];
        q_m[8] = 1'b1;
    end

    n_0 = N_1(~q_m[7:0]);
    n_1 = N_1( q_m[7:0]);

    m_0 = c_t - (n_1 - n_0);
    m_1 = c_t + (n_1 - n_0);

    if (!de_i) begin
        c_n = 'b0;

        case ({c1_i, c0_i})
            2'b00: q_n = 10'b11_0101_0100;
            2'b01: q_n = 10'b00_1010_1011;
            2'b10: q_n = 10'b01_0101_0100;
            2'b11: q_n = 10'b10_1010_1011;
        endcase
    end else begin
        if ((c_t == 0) | (n_1 == n_0)) begin
            c_n = q_m[8] ? m_1 : m_0;

            q_n = {~q_m[8], q_m[8], (q_m[8] ? q_m[7:0] : ~q_m[7:0])};
        end else begin
            if (((c_t > 0) & (n_1 > n_0)) |
                ((c_t < 0) & (n_1 < n_0))) begin
                c_n = m_0 + { q_m[8], 1'b0};

                q_n = {1'b1, q_m[8], ~q_m[7:0]};
            end else begin
                c_n = m_1 - {~q_m[8], 1'b0};

                q_n = {1'b0, q_m[8],  q_m[7:0]};
            end
        end
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        c_t <= 'b0;
        q_o <= 'b0;
    end else begin
        c_t <= c_n;
        q_o <= q_n;
    end
end

endmodule
