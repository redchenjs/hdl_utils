/*
 * test_ws28xx_ctl.sv
 *
 *  Created on: 2020-07-08 20:23
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_ws28xx_ctl;

logic clk_i;
logic rst_n_i;

logic out_sync_i;

logic bit_data_o;
logic bit_valid_o;
logic bit_ready_i;

logic  [7:0] ram_rd_addr_o;
logic [31:0] ram_rd_data_i;

ws28xx_ctl ws28xx_ctl(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .out_sync_i(out_sync_i),
    
    .bit_data_o(bit_data_o),
    .bit_valid_o(bit_valid_o),
    .bit_ready_i(bit_ready_i),

    .ram_rd_addr_o(ram_rd_addr_o),
    .ram_rd_data_i(ram_rd_data_i)
);

initial begin
    clk_i   <= 'b1;
    rst_n_i <= 'b0;

    out_sync_i  <= 'b0;
    bit_ready_i <= 'b0;

    ram_rd_data_i <= 32'haaaa_cccc;

    #2 rst_n_i <= 'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    #11 out_sync_i <= 'b1;
    #5  out_sync_i <= 'b0;

    for (integer i = 0; i < 119; i++) begin
        #50 bit_ready_i <= 'b1;
        #5  bit_ready_i <= 'b0;
    end

    #500 ram_rd_data_i <= 32'h00aa_dddd;

    for (integer i = 0; i < 119; i++) begin
        #50 bit_ready_i <= 'b1;
        #5  bit_ready_i <= 'b0;
    end

    #75 rst_n_i <= 'b0;
    #25 $stop;
end

endmodule
