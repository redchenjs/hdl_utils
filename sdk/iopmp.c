/*
 * iopmp.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdint.h>
#include <stdbool.h>

#include "iopmp.h"

// IOPMP Functions
void iopmp_init(void)
{
    PMP_CTRL_0_REG = PMP_RESET_BIT;
    PMP_CTRL_1_REG = PMP_RESET_BIT;

    PMP_CONF_0_0_BASE_REG = 0x20000000; // IRAM-APP1
    PMP_CONF_0_0_MASK_REG = 0xFFFF0000; // 0x20000000 - 0x2000FFFF
    PMP_CONF_0_1_BASE_REG = 0x00000000;
    PMP_CONF_0_1_MASK_REG = 0x00000000;
    PMP_CONF_0_2_BASE_REG = 0x00000000;
    PMP_CONF_0_2_MASK_REG = 0x00000000;
    PMP_CONF_0_3_BASE_REG = 0x00000000;
    PMP_CONF_0_3_MASK_REG = 0x00000000;
    PMP_CONF_0_4_BASE_REG = 0x00000000;
    PMP_CONF_0_4_MASK_REG = 0x00000000;
    PMP_CONF_0_5_BASE_REG = 0x00000000;
    PMP_CONF_0_5_MASK_REG = 0x00000000;
    PMP_CONF_0_6_BASE_REG = 0x00000000;
    PMP_CONF_0_6_MASK_REG = 0x00000000;
    PMP_CONF_0_7_BASE_REG = 0x00000000;
    PMP_CONF_0_7_MASK_REG = 0x00000000;

    PMP_CONF_1_0_BASE_REG = 0x20020000; // SRAM-APP1
    PMP_CONF_1_0_MASK_REG = 0xFFFF0000; // 0x20020000 - 0x2002FFFF
    PMP_CONF_1_1_BASE_REG = 0x40010000; // MAILBOX_0
    PMP_CONF_1_1_MASK_REG = 0xFFFF0000; // 0x40010000 - 0x4001FFFF
    PMP_CONF_1_2_BASE_REG = 0x40020000; // MAILBOX_1
    PMP_CONF_1_2_MASK_REG = 0xFFFF0000; // 0x40020000 - 0x4002FFFF
    PMP_CONF_1_3_BASE_REG = 0x60000000; // TIM_2
    PMP_CONF_1_3_MASK_REG = 0xFFFFFFE0; // 0x60000000 - 0x6000001F
    PMP_CONF_1_4_BASE_REG = 0x60018000; // GPIO
    PMP_CONF_1_4_MASK_REG = 0xFFFFF000; // 0x60018000 - 0x60018FFF
    PMP_CONF_1_5_BASE_REG = 0x60028000; // USI_1
    PMP_CONF_1_5_MASK_REG = 0xFFFFF000; // 0x60028000 - 0x60028FFF
    PMP_CONF_1_6_BASE_REG = 0x00000000;
    PMP_CONF_1_6_MASK_REG = 0x00000000;
    PMP_CONF_1_7_BASE_REG = 0x00000000;
    PMP_CONF_1_7_MASK_REG = 0x00000000;

    PMP_CTRL_0_REG = 0x01;
    PMP_CTRL_1_REG = 0x3f;
}

bool iopmp_get_err(uint8_t idx)
{
    if (idx) {
        return PMP_CTRL_1_REG & PMP_ERROR_BIT;
    } else {
        return PMP_CTRL_0_REG & PMP_ERROR_BIT;
    }
}

uint8_t iopmp_get_hit(uint8_t idx)
{
    if (idx) {
        return PMP_CTRL_1_REG >> 16;
    } else {
        return PMP_CTRL_0_REG >> 16;
    }
}

uint32_t iopmp_get_dump(uint8_t idx)
{
    if (idx) {
        return PMP_DUMP_1_REG;
    } else {
        return PMP_DUMP_0_REG;
    }
}
