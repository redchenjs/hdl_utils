/*
 * iopmp.h
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#ifndef INC_DRIVER_IOPMP_H_
#define INC_DRIVER_IOPMP_H_

#include <stdint.h>
#include <stdbool.h>

// IOPMP Registers
#define PMP_ERROR_BIT   (0x00000200)
#define PMP_RESET_BIT   (0x00000100)

#define PMP_CTRL_0_REG_BASE        (0x40100000)
#define PMP_CTRL_1_REG_BASE        (0x40100004)

#define PMP_DUMP_0_REG_BASE        (0x40100008)
#define PMP_DUMP_1_REG_BASE        (0x4010000C)

#define PMP_CONF_0_0_BASE_REG_BASE (0x40100010)
#define PMP_CONF_0_0_MASK_REG_BASE (0x40100014)
#define PMP_CONF_0_1_BASE_REG_BASE (0x40100018)
#define PMP_CONF_0_1_MASK_REG_BASE (0x4010001C)
#define PMP_CONF_0_2_BASE_REG_BASE (0x40100020)
#define PMP_CONF_0_2_MASK_REG_BASE (0x40100024)
#define PMP_CONF_0_3_BASE_REG_BASE (0x40100028)
#define PMP_CONF_0_3_MASK_REG_BASE (0x4010002C)
#define PMP_CONF_0_4_BASE_REG_BASE (0x40100030)
#define PMP_CONF_0_4_MASK_REG_BASE (0x40100034)
#define PMP_CONF_0_5_BASE_REG_BASE (0x40100038)
#define PMP_CONF_0_5_MASK_REG_BASE (0x4010003C)
#define PMP_CONF_0_6_BASE_REG_BASE (0x40100040)
#define PMP_CONF_0_6_MASK_REG_BASE (0x40100044)
#define PMP_CONF_0_7_BASE_REG_BASE (0x40100048)
#define PMP_CONF_0_7_MASK_REG_BASE (0x4010004C)

#define PMP_CONF_1_0_BASE_REG_BASE (0x40100050)
#define PMP_CONF_1_0_MASK_REG_BASE (0x40100054)
#define PMP_CONF_1_1_BASE_REG_BASE (0x40100058)
#define PMP_CONF_1_1_MASK_REG_BASE (0x4010005C)
#define PMP_CONF_1_2_BASE_REG_BASE (0x40100060)
#define PMP_CONF_1_2_MASK_REG_BASE (0x40100064)
#define PMP_CONF_1_3_BASE_REG_BASE (0x40100068)
#define PMP_CONF_1_3_MASK_REG_BASE (0x4010006C)
#define PMP_CONF_1_4_BASE_REG_BASE (0x40100070)
#define PMP_CONF_1_4_MASK_REG_BASE (0x40100074)
#define PMP_CONF_1_5_BASE_REG_BASE (0x40100078)
#define PMP_CONF_1_5_MASK_REG_BASE (0x4010007C)
#define PMP_CONF_1_6_BASE_REG_BASE (0x40100080)
#define PMP_CONF_1_6_MASK_REG_BASE (0x40100084)
#define PMP_CONF_1_7_BASE_REG_BASE (0x40100088)
#define PMP_CONF_1_7_MASK_REG_BASE (0x4010008C)

#define PMP_CTRL_0_REG        (*(volatile uint32_t *)PMP_CTRL_0_REG_BASE)
#define PMP_CTRL_1_REG        (*(volatile uint32_t *)PMP_CTRL_1_REG_BASE)

#define PMP_DUMP_0_REG        (*(volatile uint32_t *)PMP_DUMP_0_REG_BASE)
#define PMP_DUMP_1_REG        (*(volatile uint32_t *)PMP_DUMP_1_REG_BASE)

#define PMP_CONF_0_0_BASE_REG (*(volatile uint32_t *)PMP_CONF_0_0_BASE_REG_BASE)
#define PMP_CONF_0_0_MASK_REG (*(volatile uint32_t *)PMP_CONF_0_0_MASK_REG_BASE)
#define PMP_CONF_0_1_BASE_REG (*(volatile uint32_t *)PMP_CONF_0_1_BASE_REG_BASE)
#define PMP_CONF_0_1_MASK_REG (*(volatile uint32_t *)PMP_CONF_0_1_MASK_REG_BASE)
#define PMP_CONF_0_2_BASE_REG (*(volatile uint32_t *)PMP_CONF_0_2_BASE_REG_BASE)
#define PMP_CONF_0_2_MASK_REG (*(volatile uint32_t *)PMP_CONF_0_2_MASK_REG_BASE)
#define PMP_CONF_0_3_BASE_REG (*(volatile uint32_t *)PMP_CONF_0_3_BASE_REG_BASE)
#define PMP_CONF_0_3_MASK_REG (*(volatile uint32_t *)PMP_CONF_0_3_MASK_REG_BASE)
#define PMP_CONF_0_4_BASE_REG (*(volatile uint32_t *)PMP_CONF_0_4_BASE_REG_BASE)
#define PMP_CONF_0_4_MASK_REG (*(volatile uint32_t *)PMP_CONF_0_4_MASK_REG_BASE)
#define PMP_CONF_0_5_BASE_REG (*(volatile uint32_t *)PMP_CONF_0_5_BASE_REG_BASE)
#define PMP_CONF_0_5_MASK_REG (*(volatile uint32_t *)PMP_CONF_0_5_MASK_REG_BASE)
#define PMP_CONF_0_6_BASE_REG (*(volatile uint32_t *)PMP_CONF_0_6_BASE_REG_BASE)
#define PMP_CONF_0_6_MASK_REG (*(volatile uint32_t *)PMP_CONF_0_6_MASK_REG_BASE)
#define PMP_CONF_0_7_BASE_REG (*(volatile uint32_t *)PMP_CONF_0_7_BASE_REG_BASE)
#define PMP_CONF_0_7_MASK_REG (*(volatile uint32_t *)PMP_CONF_0_7_MASK_REG_BASE)

#define PMP_CONF_1_0_BASE_REG (*(volatile uint32_t *)PMP_CONF_1_0_BASE_REG_BASE)
#define PMP_CONF_1_0_MASK_REG (*(volatile uint32_t *)PMP_CONF_1_0_MASK_REG_BASE)
#define PMP_CONF_1_1_BASE_REG (*(volatile uint32_t *)PMP_CONF_1_1_BASE_REG_BASE)
#define PMP_CONF_1_1_MASK_REG (*(volatile uint32_t *)PMP_CONF_1_1_MASK_REG_BASE)
#define PMP_CONF_1_2_BASE_REG (*(volatile uint32_t *)PMP_CONF_1_2_BASE_REG_BASE)
#define PMP_CONF_1_2_MASK_REG (*(volatile uint32_t *)PMP_CONF_1_2_MASK_REG_BASE)
#define PMP_CONF_1_3_BASE_REG (*(volatile uint32_t *)PMP_CONF_1_3_BASE_REG_BASE)
#define PMP_CONF_1_3_MASK_REG (*(volatile uint32_t *)PMP_CONF_1_3_MASK_REG_BASE)
#define PMP_CONF_1_4_BASE_REG (*(volatile uint32_t *)PMP_CONF_1_4_BASE_REG_BASE)
#define PMP_CONF_1_4_MASK_REG (*(volatile uint32_t *)PMP_CONF_1_4_MASK_REG_BASE)
#define PMP_CONF_1_5_BASE_REG (*(volatile uint32_t *)PMP_CONF_1_5_BASE_REG_BASE)
#define PMP_CONF_1_5_MASK_REG (*(volatile uint32_t *)PMP_CONF_1_5_MASK_REG_BASE)
#define PMP_CONF_1_6_BASE_REG (*(volatile uint32_t *)PMP_CONF_1_6_BASE_REG_BASE)
#define PMP_CONF_1_6_MASK_REG (*(volatile uint32_t *)PMP_CONF_1_6_MASK_REG_BASE)
#define PMP_CONF_1_7_BASE_REG (*(volatile uint32_t *)PMP_CONF_1_7_BASE_REG_BASE)
#define PMP_CONF_1_7_MASK_REG (*(volatile uint32_t *)PMP_CONF_1_7_MASK_REG_BASE)

extern void iopmp_init(void);

extern bool iopmp_get_err(uint8_t idx);
extern uint8_t iopmp_get_hit(uint8_t idx);

extern uint32_t iopmp_get_dump(uint8_t idx);

#endif /* INC_DRIVER_IOPMP_H_ */
