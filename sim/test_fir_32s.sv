/*
 * test_comp.sv
 *
 *  Created on: 2022-01-06 20:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_comp;

localparam K = 32;
localparam N = 16;
localparam D_BITS = 16;
localparam M_BITS = 16;

logic clk_i;
logic rst_n_i;

logic clk_s_i;

logic signed [63:0] [15:0] table_sin = {
  16'd32767,  16'd32604,  16'd32117,  16'd31311,  16'd30194,  16'd28777,  16'd27073,  16'd25101,
  16'd22879,  16'd20430,  16'd17778,  16'd14949,  16'd11971,  16'd08875,  16'd05690,  16'd02449,
 -16'd00817, -16'd04074, -16'd07291, -16'd10436, -16'd13477, -16'd16384, -16'd19128, -16'd21681,
 -16'd24020, -16'd26120, -16'd27960, -16'd29522, -16'd30791, -16'd31754, -16'd32401, -16'd32726,
 -16'd32726, -16'd32401, -16'd31754, -16'd30791, -16'd29522, -16'd27960, -16'd26120, -16'd24020,
 -16'd21681, -16'd19128, -16'd16383, -16'd13477, -16'd10436, -16'd07291, -16'd04074, -16'd00817,
  16'd02449,  16'd05690,  16'd08875,  16'd11971,  16'd14949,  16'd17778,  16'd20430,  16'd22879,
  16'd25101,  16'd27073,  16'd28777,  16'd30194,  16'd31311,  16'd32117,  16'd32604,  16'd32767
};

logic signed           [D_BITS-1:0] x_i;
logic signed [K/2-1:0] [M_BITS-1:0] a_i = {
  16'd000,	16'd001,  16'd001,  16'd003,
  16'd006,	16'd010,  16'd015,  16'd022,	
  16'd031,	16'd040,  16'd051,  16'd061,	
  16'd070,	16'd078,  16'd084,  16'd087	
};

// logic signed [K/2-1:0] [M_BITS-1:0] a_i = {
//   16'd002,  16'd003,  16'd000, -16'd004,	
//  -16'd009, -16'd005,  16'd007,  16'd021,	
//   16'd019, -16'd006, -16'd041, -16'd055,	
// - 16'd013,  16'd088,  16'd211,  16'd295
// };

// logic signed [K/2-1:0] [M_BITS-1:0] a_i = {
//   16'd00,  16'd00,  16'd00,  16'd00,  16'd00,  16'd00,  16'd00,  16'd00,
//   16'd01,  16'd01,  16'd01,  16'd01,  16'd02,  16'd02,  16'd03,  16'd03,
//   16'd04,  16'd04,  16'd04,  16'd05,  16'd05,  16'd06,  16'd06,  16'd06,
//   16'd06,  16'd05,  16'd05,  16'd04,  16'd03,  16'd02,  16'd01,  16'd00,
//  -16'd02, -16'd03, -16'd05, -16'd06, -16'd08, -16'd09, -16'd10, -16'd11,
//  -16'd11, -16'd11, -16'd11, -16'd10, -16'd09, -16'd07, -16'd04, -16'd01,
//   16'd03,  16'd07,  16'd11,  16'd16,  16'd22,  16'd27,  16'd32,  16'd37,
//   16'd42,  16'd47,  16'd51,  16'd55,  16'd58,  16'd61,  16'd62,  16'd63
// };

logic signed [D_BITS+M_BITS-1:0] y_o;

fir #(
    .K(K),
    .D_BITS(D_BITS),
    .M_BITS(M_BITS)
) fir (
    .clk_i(clk_s_i),
    .rst_n_i(rst_n_i),

    .x_i(x_i),
    .a_i(a_i),

    .y_o(y_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    clk_s_i <= 1'b1;

    #2 rst_n_i <= 1'b1;
end

always begin
    #10 clk_i <= ~clk_i;
end

always begin
    #100 clk_s_i <= ~clk_s_i;
end

logic         [7:0] cnt_s;
logic         [5:0] addr_s;
logic signed [15:0] data_s;

logic         [5:0] addr_c;
logic signed [15:0] data_c;

always @(posedge clk_i or negedge rst_n_i) begin
	if (!rst_n_i) begin
        cnt_s  <= 'b0;
		addr_s <= 'b0;
		data_s <= 'b0;
	end else begin
        cnt_s  <= cnt_s + 1;
		addr_s <= addr_s + (cnt_s == 8'hff);
		data_s <= table_sin[addr_s];
	end
end

always @(posedge clk_i or negedge rst_n_i) begin
	if (!rst_n_i) begin
		addr_c <= 'b0;
		data_c <= 'b0;
	end else begin
		addr_c <= addr_c + 1;
		data_c <= table_sin[addr_c];
	end
end

wire signed [31:0] signal = $signed(data_s + 32768) * $signed(data_c);

always @(posedge clk_s_i or negedge rst_n_i) begin
	if (!rst_n_i) begin
		x_i <= 'b0;
	end else begin
        x_i <= signal[31] ? ~signal[30:15] + 1: signal[30:15];
	end
end

always begin
    #5000000 rst_n_i <= 1'b1;
    #25 $finish;
end

endmodule
