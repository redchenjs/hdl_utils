/*
 * ws28xx_ctl.sv
 *
 *  Created on: 2020-04-06 23:09
 *      Author: Jack Chen <redchenjs@live.com>
 */

module ws28xx_ctl(
    input logic clk_i,
    input logic rst_n_i,

    input logic out_sync_i,

    output logic bit_data_o,
    output logic bit_valid_o,
    input  logic bit_ready_i,

    output logic  [7:0] ram_rd_addr_o,
    input  logic [31:0] ram_rd_data_i
);

typedef enum logic [1:0] {
    IDLE,       // Idle
    READ_RAM,   // Read RAM Data
    SEND_BIT,   // Send Bit Code
    SYNC_BIT    // Sync Bit Code
} state_t;

state_t ctl_sta;

logic       bit_st;
logic [4:0] bit_sel;

logic bit_valid, bit_data;

logic  [7:0] rd_addr;
logic [23:0] rd_data;

wire bit_next = bit_st | bit_ready_i;

wire data_next = (bit_sel == 5'd23);
wire data_done = (rd_addr == 8'h00);

assign bit_valid_o  = bit_valid;
assign bit_data_o = bit_data;

assign ram_rd_addr_o = rd_addr;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        ctl_sta <= IDLE;

        rd_addr <= 'b0;
        rd_data <= 'b0;

        bit_st  <= 'b0;
        bit_sel <= 'b0;

        bit_data  <= 'b0;
        bit_valid <= 'b0;
    end else begin
        case (ctl_sta)
            IDLE:
                ctl_sta <= out_sync_i ? READ_RAM : ctl_sta;
            READ_RAM:
                ctl_sta <= SEND_BIT;
            SEND_BIT:
                ctl_sta <= (bit_next & data_next) ? (data_done ? SYNC_BIT : READ_RAM) : ctl_sta;
            SYNC_BIT:
                ctl_sta <= out_sync_i ? READ_RAM : (bit_next ? IDLE : ctl_sta);
            default:
                ctl_sta <= IDLE;
        endcase

        rd_addr <= (ctl_sta == READ_RAM) ? ram_rd_data_i[31:24] : rd_addr;
        rd_data <= (ctl_sta == READ_RAM) ? ram_rd_data_i[23:0] : rd_data;

        bit_st  <= (ctl_sta != SEND_BIT) & (bit_st | data_done);
        bit_sel <= (ctl_sta == SEND_BIT) ? bit_sel + bit_next : 5'h00;

        bit_data  <= (ctl_sta == SEND_BIT) & bit_next ? rd_data[5'd23 - bit_sel] : bit_data;
        bit_valid <= (ctl_sta == SEND_BIT) & bit_next;
    end
end

endmodule
