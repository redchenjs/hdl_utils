/*
 * apb_enum.sv
 *
 *  Created on: 2023-05-17 11:18
 *      Author: Jack Chen <redchenjs@live.com>
 */

package apb_enum;
    typedef enum logic {
        APB_PROT_0_NORMAL      = 1'b0,
        APB_PROT_0_PRIVILEGED  = 1'b1,
        APB_PROT_1_SECURE      = 1'b0,
        APB_PROT_1_NON_SECURE  = 1'b1,
        APB_PROT_2_DATA        = 1'b0,
        APB_PROT_2_INSTRUCTION = 1'b1
    } apb_prot_t;
endpackage
