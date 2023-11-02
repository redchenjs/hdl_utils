/*
 * apb_pmu.sv
 *
 *  Created on: 2023-05-15 20:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

module apb_pmu #(
    parameter A_WIDTH = 32,
    parameter D_WIDTH = 32
) (
    input logic pclk_i,
    input logic presetn_i,

    input logic               psel_i,
    input logic [A_WIDTH-1:0] paddr_i,
    input logic               pwrite_i,
    input logic [D_WIDTH-1:0] pwdata_i,
    input logic               penable_i,

    output logic [D_WIDTH-1:0] prdata_o,

    output logic rst_n_o
);

typedef struct packed {
    logic [31:1] rsvd;
    logic        rst_n;
} pmu_ctrl_t;

pmu_ctrl_t pmu_ctrl_0;

wire wr_en = psel_i &  penable_i &  pwrite_i;
wire rd_en = psel_i & !penable_i & !pwrite_i;

assign rst_n_o = pmu_ctrl_0.rst_n;

always_ff @(posedge pclk_i or negedge presetn_i)
begin
    if (!presetn_i) begin
        prdata_o <= 'b0;

        pmu_ctrl_0 <= 'b0;
    end else begin
        if (wr_en) begin
            case (paddr_i[7:0])
                8'h00: begin
                    pmu_ctrl_0 <= pwdata_i;
                end
            endcase
        end

        if (rd_en) begin
            case (paddr_i[7:0])
                8'h00: begin
                    prdata_o <= pmu_ctrl_0;
                end
                default: begin
                    prdata_o <= 'b0;
                end
            endcase
        end
    end
end

endmodule
