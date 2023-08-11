/*
 * pmu.h
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#ifndef INC_DRIVER_PMU_H_
#define INC_DRIVER_PMU_H_

// PMU Registers
#define PMU_CTRL_REG_BASE   (0x60030000)
#define PMU_RST_N_BIT       (0x00000001)

#define PMU_CTRL_REG        (*(volatile uint32_t *)PMU_CTRL_REG_BASE)

extern void pmu_set_reset(int val);

#endif /* INC_DRIVER_PMU_H_ */
