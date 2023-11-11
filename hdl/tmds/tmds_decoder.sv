/*
 * tmds_decoder.sv
 *
 *  Created on: 2023-11-11 17:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module tmds_decoder(
    input logic clk_i,
    input logic rst_n_i,

    input  logic [9:0] d_i,
    output logic [7:0] q_o,

    output logic de_o,
    output logic c1_o,
    output logic c0_o
);

logic [7:0] q_m;
logic [7:0] q_n;

logic de, c1, c0;

always_comb begin
    case (d_i)
        10'b11_0101_0100: {de, c1, c0} = 3'b0_00;
        10'b00_1010_1011: {de, c1, c0} = 3'b0_01;
        10'b01_0101_0100: {de, c1, c0} = 3'b0_10;
        10'b10_1010_1011: {de, c1, c0} = 3'b0_11;
        default:          {de, c1, c0} = 3'b1_00;
    endcase

    q_m = d_i[9] ? ~d_i[7:0] : d_i[7:0];

    if (d_i[8]) begin
        q_n[0] = q_m[0];
        q_n[1] = q_m[1] ^ q_m[0];
        q_n[2] = q_m[2] ^ q_m[1];
        q_n[3] = q_m[3] ^ q_m[2];
        q_n[4] = q_m[4] ^ q_m[3];
        q_n[5] = q_m[5] ^ q_m[4];
        q_n[6] = q_m[6] ^ q_m[5];
        q_n[7] = q_m[7] ^ q_m[6];
    end else begin
        q_n[0] = q_m[0];
        q_n[1] = q_m[1] ^~ q_m[0];
        q_n[2] = q_m[2] ^~ q_m[1];
        q_n[3] = q_m[3] ^~ q_m[2];
        q_n[4] = q_m[4] ^~ q_m[3];
        q_n[5] = q_m[5] ^~ q_m[4];
        q_n[6] = q_m[6] ^~ q_m[5];
        q_n[7] = q_m[7] ^~ q_m[6];
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        q_o <= 'b0;

        de_o <= 'b0;
        c1_o <= 'b0;
        c0_o <= 'b0;
    end else begin
        if (de) begin
            q_o <= q_n;
        end

        de_o <= de;
        c1_o <= c1;
        c0_o <= c0;
    end
end

endmodule
