/*
 * axi4_pkg.sv
 *
 *  Created on: 2023-05-17 11:18
 *      Author: Jack Chen <redchenjs@live.com>
 */

package axi4_pkg;
    typedef logic [3:0] axi_id_t;
    typedef logic [7:0] axi_len_t;

    typedef enum logic [2:0] {
        AXI_SIZE_1_BYTE    = 3'b000,
        AXI_SIZE_2_BYTES   = 3'b001,
        AXI_SIZE_4_BYTES   = 3'b010,
        AXI_SIZE_8_BYTES   = 3'b011,
        AXI_SIZE_16_BYTES  = 3'b100,
        AXI_SIZE_32_BYTES  = 3'b101,
        AXI_SIZE_64_BYTES  = 3'b110,
        AXI_SIZE_128_BYTES = 3'b111
    } axi_size_t;

    typedef enum logic [1:0] {
        AXI_BURST_FIXED    = 2'b00,
        AXI_BURST_INCR     = 2'b01,
        AXI_BURST_WRAP     = 2'b10,
        AXI_BURST_RESERVED = 2'b11
    } axi_burst_t;

    typedef enum logic {
        AXI_LOCK_NORMAL    = 1'b0,
        AXI_LOCK_EXCLUSIVE = 1'b1
    } axi_lock_t;

    typedef enum logic [3:0] {
        AXI_AWCACHE_BUFFERABLE     = 4'b0001,
        AXI_AWCACHE_MODIFIABLE     = 4'b0010,
        AXI_AWCACHE_OTHER_ALLOCATE = 4'b0100,
        AXI_AWCACHE_ALLOCATE       = 4'b1000
    } axi_awcache_t;

    typedef enum logic [3:0] {
        AXI_ARCACHE_BUFFERABLE     = 4'b0001,
        AXI_ARCACHE_MODIFIABLE     = 4'b0010,
        AXI_ARCACHE_ALLOCATE       = 4'b0100,
        AXI_ARCACHE_OTHER_ALLOCATE = 4'b1000
    } axi_arcache_t;

    typedef enum logic [2:0] {
        AXI_PROT_PRIVILEGED  = 3'b001,
        AXI_PROT_NON_SECURE  = 3'b010,
        AXI_PROT_INSTRUCTION = 3'b100
    } ahb_prot_t;

    typedef enum logic [1:0] {
        AXI_RESP_OKAY   = 2'b00,
        AXI_RESP_EXOKAY = 2'b01,
        AXI_RESP_SLVERR = 2'b10,
        AXI_RESP_DECERR = 2'b11
    } axi_resp_t;

    typedef logic [3:0] axi_qos_t;
    typedef logic [3:0] axi_region_t;

    typedef enum logic {
        AXI_CACTIVE_NOT_REQUIRED = 1'b0,
        AXI_CACTIVE_REQUIRED     = 1'b1
    } axi_cactive_t;
endpackage
