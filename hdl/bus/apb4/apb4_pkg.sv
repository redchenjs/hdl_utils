/*
 * apb4_pkg.sv
 *
 *  Created on: 2023-05-17 11:18
 *      Author: Jack Chen <redchenjs@live.com>
 */

package apb4_pkg;
    typedef enum logic [2:0] {
        APB_PROT_PRIVILEGED  = 3'b001,
        APB_PROT_NON_SECURE  = 3'b010,
        APB_PROT_INSTRUCTION = 3'b100
    } apb_prot_t;
endpackage
