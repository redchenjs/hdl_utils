/*
 * axi4_pkg.sv
 *
 *  Created on: 2023-05-17 11:18
 *      Author: Jack Chen <redchenjs@live.com>
 */

package axi4_pkg;
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

    typedef enum logic [2:0] {
        AXI_BRESP_OKAY        = 3'b000,
        AXI_BRESP_EXOKAY      = 3'b001,
        AXI_BRESP_SLVERR      = 3'b010,
        AXI_BRESP_DECERR      = 3'b011,
        AXI_BRESP_DEFER       = 3'b100,
        AXI_BRESP_TRANSFAULT  = 3'b101,
        AXI_BRESP_RESERVED    = 3'b110,
        AXI_BRESP_UNSUPPORTED = 3'b111
    } axi_bresp_t;

    typedef enum logic [2:0] {
        AXI_RRESP_OKAY       = 3'b000,
        AXI_RRESP_EXOKAY     = 3'b001,
        AXI_RRESP_SLVERR     = 3'b010,
        AXI_RRESP_DECERR     = 3'b011,
        AXI_RRESP_PREFETCHED = 3'b100,
        AXI_RRESP_TRANSFAULT = 3'b101,
        AXI_RRESP_OKAYDIRTY  = 3'b110,
        AXI_RRESP_RESERVED   = 3'b111
    } axi_rresp_t;

    typedef enum logic [1:0] {
        AXI_BUSY_NOT_BUSY       = 2'b00,
        AXI_BUSY_OPTIMALLY_BUSY = 2'b01,
        AXI_BUSY_QUITE_BUSY     = 2'b10,
        AXI_BUSY_VERY_BUSY      = 2'b11
    } axi_busy_t;

    typedef enum logic {
        AXI_AWCACHE_0_NON_BUFFERABLE     = 1'b0,
        AXI_AWCACHE_0_BUFFERABLE         = 1'b1,
        AXI_AWCACHE_1_NON_MODIFIABLE     = 1'b0,
        AXI_AWCACHE_1_MODIFIABLE         = 1'b1,
        AXI_AWCACHE_2_NON_OTHER_ALLOCATE = 1'b0,
        AXI_AWCACHE_2_OTHER_ALLOCATE     = 1'b1,
        AXI_AWCACHE_3_NON_ALLOCATE       = 1'b0,
        AXI_AWCACHE_3_ALLOCATE           = 1'b1
    } axi_awcache_t;

    typedef enum logic {
        AXI_ARCACHE_0_NON_BUFFERABLE     = 1'b0,
        AXI_ARCACHE_0_BUFFERABLE         = 1'b1,
        AXI_ARCACHE_1_NON_MODIFIABLE     = 1'b0,
        AXI_ARCACHE_1_MODIFIABLE         = 1'b1,
        AXI_ARCACHE_2_NON_ALLOCATE       = 1'b0,
        AXI_ARCACHE_2_ALLOCATE           = 1'b1,
        AXI_ARCACHE_3_NON_OTHER_ALLOCATE = 1'b0,
        AXI_ARCACHE_3_OTHER_ALLOCATE     = 1'b1
    } axi_arcache_t;
endpackage
