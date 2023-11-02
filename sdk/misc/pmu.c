/*
 * pmu.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdint.h>

#include "pmu.h"

// PMU Functions
void pmu_set_reset(int val)
{
    if (val) {
        PMU_CTRL_REG |= PMU_RST_N_BIT;
    } else {
        PMU_CTRL_REG &=~PMU_RST_N_BIT;
    }
}
