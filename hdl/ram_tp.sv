/*
 * ram_tp.sv
 *
 *  Created on: 2022-12-22 22:10
 *      Author: Jack Chen <redchenjs@live.com>
 */

module ram_tp #(
    parameter I_WIDTH = 8,
    parameter I_DEPTH = 8,
    parameter O_WIDTH = 8,
    parameter O_DEPTH = 8,
    parameter logic OUT_REG = 1'b1
) (
    input logic wr_clk_i,

    input logic                       wr_en_i,
    input logic [$clog2(I_DEPTH)-1:0] wr_addr_i,
    input logic [I_WIDTH/8-1:0] [7:0] wr_data_i,
    input logic       [I_WIDTH/8-1:0] wr_byte_en_i,

    input logic rd_clk_i,

    input  logic                       rd_en_i,
    input  logic [$clog2(O_DEPTH)-1:0] rd_addr_i,
    output logic         [O_WIDTH-1:0] rd_data_o
);

generate
    wire [$clog2(O_DEPTH)-1:0] wr_addr_ext = {wr_addr_i[$clog2(O_DEPTH)-$clog2(I_WIDTH/O_WIDTH)-1:0], {$clog2(I_WIDTH/O_WIDTH){1'b0}}};
    wire [$clog2(I_DEPTH)-1:0] rd_addr_ext = {rd_addr_i[$clog2(I_DEPTH)-$clog2(O_WIDTH/I_WIDTH)-1:0], {$clog2(O_WIDTH/I_WIDTH){1'b0}}};

    if (O_WIDTH >= I_WIDTH) begin
        logic [I_WIDTH/8-1:0] [7:0] ram[I_DEPTH];

        always @(posedge wr_clk_i) begin
            if (wr_en_i) begin
                for (int i = 0; i < I_WIDTH/8; i++) begin
                    if (wr_byte_en_i[i]) begin
                        ram[wr_addr_i][i] <= wr_data_i[i];
                    end
                end
            end
        end

        for (genvar k = 0; k < O_WIDTH/I_WIDTH; k++) begin
            if (!OUT_REG) begin
                assign rd_data_o[k * I_WIDTH + I_WIDTH - 1 :  k * I_WIDTH] = ram[rd_addr_ext + k];
            end else begin
                always @(posedge rd_clk_i) begin
                    if (rd_en_i) begin
                        rd_data_o[k * I_WIDTH + I_WIDTH - 1 :  k * I_WIDTH] <= ram[rd_addr_ext + k];
                    end
                end
            end
        end
    end else begin
        logic [O_WIDTH/8-1:0] [7:0] ram[O_DEPTH];

        for (genvar k = 0; k < I_WIDTH/8; k++) begin
            always @(posedge wr_clk_i) begin
                if (wr_en_i & wr_byte_en_i[k]) begin
                    ram[wr_addr_ext + k[$clog2(I_WIDTH/8)-1:$clog2(I_WIDTH/O_WIDTH)]][k[$clog2(I_WIDTH/O_WIDTH)-1:0]] <= wr_data_i[k];
                end
            end
        end

        if (!OUT_REG) begin
            assign rd_data_o = ram[rd_addr_i];
        end else begin
            always @(posedge rd_clk_i) begin
                if (rd_en_i) begin
                    rd_data_o <= ram[rd_addr_i];
                end
            end
        end
    end
endgenerate

endmodule
