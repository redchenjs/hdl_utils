/*
 * vendor_pkg.sv
 *
 *  Created on: 2023-11-10 01:10
 *      Author: Jack Chen <redchenjs@live.com>
 */

package vendor_pkg;
    typedef enum {
        VENDOR_XILINX = 0,
        VENDOR_ALTERA = 1,
        VENDOR_GOWIN  = 2
    } vendor_t;
endpackage
