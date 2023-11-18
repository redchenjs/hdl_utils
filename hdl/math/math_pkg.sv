/*
 * math_pkg.sv
 *
 *  Created on: 2023-11-19 13:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1 ns / 1 ps

package math_pkg;
    typedef enum int {
        MATH_OP_AND  = 'h0000,
        MATH_OP_OR   = 'h0001,
        MATH_OP_XOR  = 'h0002,
        MATH_OP_NOT  = 'h0003,
        MATH_OP_NAND = 'h0004,
        MATH_OP_NOR  = 'h0005,
        MATH_OP_XNOR = 'h0006,

        MATH_OP_SHL  = 'h0007,
        MATH_OP_SHR  = 'h0008,
        MATH_OP_ROL  = 'h0009,
        MATH_OP_ROR  = 'h000a,

        MATH_OP_ADD  = 'h0010,
        MATH_OP_SUB  = 'h0011,
        MATH_OP_MUL  = 'h0012,
        MATH_OP_DIV  = 'h0013
    } math_op_t;
endpackage
