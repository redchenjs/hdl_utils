/*
 * ahb_lite_pkg.sv
 *
 *  Created on: 2023-11-04 01:06
 *      Author: Jack Chen <redchenjs@live.com>
 */

package ahb_lite_pkg;
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

    typedef enum logic [3:0] {
        AHB_PROT_DATA       = 4'b0001,
        AHB_PROT_PRIVILEGED = 4'b0010,
        AHB_PROT_BUFFERABLE = 4'b0100,
        AHB_PROT_CACHEABLE  = 4'b1000
    } ahb_prot_t;
endpackage
