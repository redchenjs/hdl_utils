/*
 * lfsr.sv
 *
 *  Created on: 2020-07-09 22:33
 *      Author: Jack Chen <redchenjs@live.com>
 */

module lfsr #(
    parameter N = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    output logic [N-1:0] data_o
);

logic data_t;

// Reference: http://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
always_comb begin
    case (N)
        'd3:
            data_t = data_o[2] ^~ data_o[1];
        'd4:
            data_t = data_o[3] ^~ data_o[2];
        'd5:
            data_t = data_o[4] ^~ data_o[2];
        'd6:
            data_t = data_o[5] ^~ data_o[4];
        'd7:
            data_t = data_o[6] ^~ data_o[5];
        'd8:
            data_t = data_o[7] ^~ data_o[5] ^~ data_o[4] ^~ data_o[3];
        'd9:
            data_t = data_o[8] ^~ data_o[4];
        'd10:
            data_t = data_o[9] ^~ data_o[6];
        'd11:
            data_t = data_o[10] ^~ data_o[8];
        'd12:
            data_t = data_o[11] ^~ data_o[5] ^~ data_o[3] ^~ data_o[0];
        'd13:
            data_t = data_o[12] ^~ data_o[3] ^~ data_o[2] ^~ data_o[0];
        'd14:
            data_t = data_o[13] ^~ data_o[4] ^~ data_o[2] ^~ data_o[0];
        'd15:
            data_t = data_o[14] ^~ data_o[13];
        'd16:
            data_t = data_o[15] ^~ data_o[14] ^~ data_o[12] ^~ data_o[3];
        'd17:
            data_t = data_o[16] ^~ data_o[13];
        'd18:
            data_t = data_o[17] ^~ data_o[10];
        'd19:
            data_t = data_o[18] ^~ data_o[5] ^~ data_o[1] ^~ data_o[0];
        'd20:
            data_t = data_o[19] ^~ data_o[16];
        'd21:
            data_t = data_o[20] ^~ data_o[18];
        'd22:
            data_t = data_o[21] ^~ data_o[20];
        'd23:
            data_t = data_o[22] ^~ data_o[17];
        'd24:
            data_t = data_o[23] ^~ data_o[22] ^~ data_o[21] ^~ data_o[16];
        'd25:
            data_t = data_o[24] ^~ data_o[21];
        'd26:
            data_t = data_o[25] ^~ data_o[5] ^~ data_o[1] ^~ data_o[0];
        'd27:
            data_t = data_o[26] ^~ data_o[4] ^~ data_o[1] ^~ data_o[0];
        'd28:
            data_t = data_o[27] ^~ data_o[24];
        'd29:
            data_t = data_o[28] ^~ data_o[26];
        'd30:
            data_t = data_o[29] ^~ data_o[5] ^~ data_o[3] ^~ data_o[0];
        'd31:
            data_t = data_o[30] ^~ data_o[27];
        'd32:
            data_t = data_o[31] ^~ data_o[21] ^~ data_o[1] ^~ data_o[0];
    endcase
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        data_o <= 'b0;
    end else begin
        data_o <= {data_o[N-2:0], data_t};
    end
end

endmodule
