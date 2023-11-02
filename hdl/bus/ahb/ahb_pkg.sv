/*
 * ahb_pkg.sv
 *
 *  Created on: 2023-05-17 11:18
 *      Author: Jack Chen <redchenjs@live.com>
 */

package ahb_pkg;
    typedef enum logic [1:0] {
        AHB_TRANS_IDLE   = 2'b00,
        AHB_TRANS_BUSY   = 2'b01,
        AHB_TRANS_NONSEQ = 2'b10,
        AHB_TRANS_SEQ    = 2'b11
    } ahb_trans_t;

    typedef enum logic [2:0] {
        AHB_SIZE_8_BIT    = 3'b000,
        AHB_SIZE_16_BIT   = 3'b001,
        AHB_SIZE_32_BIT   = 3'b010,
        AHB_SIZE_64_BIT   = 3'b011,
        AHB_SIZE_128_BIT  = 3'b100,
        AHB_SIZE_256_BIT  = 3'b101,
        AHB_SIZE_512_BIT  = 3'b110,
        AHB_SIZE_1024_BIT = 3'b111
    } ahb_size_t;

    typedef enum logic [2:0] {
        AHB_BURST_SINGLE = 3'b000,
        AHB_BURST_INCR   = 3'b001,
        AHB_BURST_WRAP4  = 3'b010,
        AHB_BURST_INCR4  = 3'b011,
        AHB_BURST_WRAP8  = 3'b100,
        AHB_BURST_INCR8  = 3'b101,
        AHB_BURST_WRAP16 = 3'b110,
        AHB_BURST_INCR16 = 3'b111
    } ahb_burst_t;

    typedef enum logic {
        AHB_PROT_0_OPCODE = 1'b0,
        AHB_PROT_0_DATA   = 1'b1
    } ahb_prot_0_t;

    typedef enum logic {
        AHB_PROT_1_USER       = 1'b0,
        AHB_PROT_1_PRIVILEGED = 1'b1
    } ahb_prot_1_t;

    typedef enum logic {
        AHB_PROT_2_NON_BUFFERABLE = 1'b0,
        AHB_PROT_2_BUFFERABLE     = 1'b1
    } ahb_prot_2_t;

    typedef enum logic {
        AHB_PROT_3_NON_CACHEABLE = 1'b0,
        AHB_PROT_3_CACHEABLE     = 1'b1
    } ahb_prot_3_t;

    typedef struct {
        ahb_prot_0_t prot_0;
        ahb_prot_1_t prot_1;
        ahb_prot_2_t prot_2;
        ahb_prot_3_t prot_3;
    } ahb_prot_t;

    typedef enum logic [1:0] {
        AHB_RESP_OKAY  = 2'b00,
        AHB_RESP_ERROR = 2'b01,
        AHB_RESP_RETRY = 2'b10,
        AHB_RESP_SPLIT = 2'b11
    } ahb_resp_t;

    typedef logic  [3:0] ahb_master_t;
    typedef logic [15:0] ahb_split_t;
endpackage
