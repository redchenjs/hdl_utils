/*
 * test_data_hs.sv
 *
 *  Created on: 2021-07-12 15:23
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_data_hs;

parameter WIDTH = 32;

logic clk_i;
logic rst_n_i;

logic [WIDTH-1:0] in_data_i;
logic             in_valid_i;
logic             in_ready_o;

logic [WIDTH-1:0] out_data_o;
logic             out_valid_o;
logic             out_ready_i;

logic [WIDTH-1:0] out_data_s;

data_hs #(
    .WIDTH(WIDTH)
) data_hs (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .in_data_i(in_data_i),
    .in_valid_i(in_valid_i),
    .in_ready_o(in_ready_o),

    .out_data_o(out_data_o),
    .out_valid_o(out_valid_o),
    .out_ready_i(out_ready_i)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        in_data_i  <= 32'hdead_beef;
        in_valid_i <= 1'b1;
    end else begin
        if (in_ready_o) begin
            in_data_i  <= in_data_i + 1'b1;
            in_valid_i <= 1'b0;
        end
    end
end

always @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        out_data_s  <= 'b0;
        out_ready_i <= 'b0;
    end else begin
        if (out_valid_o) begin
            out_data_s  <= out_data_o;
            out_ready_i <= 1'b1;
        end else begin
            out_ready_i <= 1'b0;
        end
    end
end

always begin
    #7500 rst_n_i <= 1'b0;
    #25 $finish;
end

endmodule
