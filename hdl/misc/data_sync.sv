/*
 * data_sync.sv
 *
 *  Created on: 2021-06-09 16:38
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

module data_sync #(
    parameter int S_STAGE = 2,
    parameter int I_VALUE = 0,
    parameter int D_WIDTH = 8
) (
    input logic clk_i,
    input logic rst_n_i,

    input  logic [D_WIDTH-1:0] data_i,
    output logic [D_WIDTH-1:0] data_o
);

generate
    // No Sync
    if (S_STAGE == 0) begin
        assign data_o = data_i;
    end

    // Two-Stage Sync: Falling Edge + Rising Edge
    if (S_STAGE == 1) begin
        logic [1:0] [D_WIDTH-1:0] data_t;

        always_ff @(negedge clk_i or negedge rst_n_i)
        begin
            if (!rst_n_i) begin
                data_t[0] <= I_VALUE;
            end else begin
                data_t[0] <= data_i;
            end
        end

        always_ff @(posedge clk_i or negedge rst_n_i)
        begin
            if (!rst_n_i) begin
                data_t[1] <= I_VALUE;
            end else begin
                data_t[1] <= data_t[0];
            end
        end

        assign data_o = data_t[1];
    end

    // Multi-Stage Sync: Rising Edge
    if (S_STAGE >= 2) begin
        logic [S_STAGE-1:0] [D_WIDTH-1:0] data_t;

        always_ff @(posedge clk_i or negedge rst_n_i)
        begin
            if (!rst_n_i) begin
                data_t <= {S_STAGE{I_VALUE[D_WIDTH-1:0]}};
            end else begin
                data_t <= {data_t[S_STAGE-2:0], data_i};
            end
        end

        assign data_o = data_t[S_STAGE-1];
    end
endgenerate

endmodule
