/*
 * mailbox.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdint.h>
#include <string.h>
#include <stdbool.h>

#include "mailbox.h"

// Mailbox Functions
static volatile uint32_t *MBOX_L_CTRL_0_REG_BASE = NULL;
static volatile uint32_t *MBOX_L_CTRL_1_REG_BASE = NULL;
static volatile uint32_t *MBOX_L_DATA_0_RAM_BASE = NULL;

static volatile uint32_t *MBOX_R_CTRL_0_REG_BASE = NULL;
static volatile uint32_t *MBOX_R_CTRL_1_REG_BASE = NULL;
static volatile uint32_t *MBOX_R_DATA_0_RAM_BASE = NULL;

#define MBOX_L_CTRL_0_REG   (*(volatile uint32_t *)MBOX_L_CTRL_0_REG_BASE)
#define MBOX_L_CTRL_1_REG   (*(volatile uint32_t *)MBOX_L_CTRL_1_REG_BASE)
#define MBOX_R_CTRL_0_REG   (*(volatile uint32_t *)MBOX_R_CTRL_0_REG_BASE)
#define MBOX_R_CTRL_1_REG   (*(volatile uint32_t *)MBOX_R_CTRL_1_REG_BASE)

uint8_t mail_id = 0;

bool mail_acked = false;
bool mail_pending = false;

void mailbox_irq_handler(void)
{
    if (MBOX_L_CTRL_1_REG & MBOX_INTR_BIT) {
        MBOX_L_CTRL_1_REG &=~MBOX_INTR_BIT;

        mail_acked = true;
    }

    if (MBOX_L_CTRL_0_REG & MBOX_INTR_BIT) {
        MBOX_L_CTRL_0_REG &=~MBOX_INTR_BIT;

        mail_pending = true;
    }
}

void mailbox_init(uint8_t core_id)
{
    if (core_id == 0) {
        MBOX_L_CTRL_0_REG_BASE = (volatile uint32_t *)MBOX_0_CTRL_0_REG_BASE;
        MBOX_L_CTRL_1_REG_BASE = (volatile uint32_t *)MBOX_0_CTRL_1_REG_BASE;
        MBOX_L_DATA_0_RAM_BASE = (volatile uint32_t *)MBOX_0_DATA_0_RAM_BASE;

        MBOX_R_CTRL_0_REG_BASE = (volatile uint32_t *)MBOX_1_CTRL_0_REG_BASE;
        MBOX_R_CTRL_1_REG_BASE = (volatile uint32_t *)MBOX_1_CTRL_1_REG_BASE;
        MBOX_R_DATA_0_RAM_BASE = (volatile uint32_t *)MBOX_1_DATA_0_RAM_BASE;
    } else {
        MBOX_L_CTRL_0_REG_BASE = (volatile uint32_t *)MBOX_1_CTRL_0_REG_BASE;
        MBOX_L_CTRL_1_REG_BASE = (volatile uint32_t *)MBOX_1_CTRL_1_REG_BASE;
        MBOX_L_DATA_0_RAM_BASE = (volatile uint32_t *)MBOX_1_DATA_0_RAM_BASE;

        MBOX_R_CTRL_0_REG_BASE = (volatile uint32_t *)MBOX_0_CTRL_0_REG_BASE;
        MBOX_R_CTRL_1_REG_BASE = (volatile uint32_t *)MBOX_0_CTRL_1_REG_BASE;
        MBOX_R_DATA_0_RAM_BASE = (volatile uint32_t *)MBOX_0_DATA_0_RAM_BASE;
    }

    MBOX_L_CTRL_0_REG = 0x00000000;
    MBOX_L_CTRL_1_REG = 0x00000000;

    MBOX_ENABLE_IRQ();
}

bool mailbox_check_acked(void)
{
    return mail_acked;
}

bool mailbox_check_pending(void)
{
    return mail_pending;
}

int mailbox_read_ack(uint8_t *id)
{
    *id = MBOX_L_CTRL_1_REG & 0xff;

    mail_acked = false;

    MBOX_L_CTRL_1_REG &=~MBOX_FULL_BIT;

    return 0;
}

int mailbox_read_message(uint8_t *id, void *buff, uint32_t buff_size)
{
    uint16_t size = (MBOX_L_CTRL_0_REG & 0x7fff00) >> 8;

    if (size > buff_size) {
        return -1;
    }

    *id = MBOX_L_CTRL_0_REG & 0xff;

    memcpy(buff, (void *)MBOX_L_DATA_0_RAM_BASE, size);

    mail_pending = false;

    MBOX_L_CTRL_0_REG &=~MBOX_FULL_BIT;

    return size;
}

int mailbox_send_ack(uint8_t id)
{
    if (MBOX_R_CTRL_1_REG & MBOX_FULL_BIT) {
        return -1;
    }

    MBOX_R_CTRL_1_REG = id | MBOX_FULL_BIT | MBOX_INTR_BIT;

    return 0;
}

int mailbox_send_message(uint8_t id, const void *buff, uint32_t len)
{
    if (MBOX_R_CTRL_0_REG & MBOX_FULL_BIT) {
        return -1;
    }

    if (len > MBOX_RAM_SIZE) {
        return -2;
    }

    memcpy((void *)MBOX_R_DATA_0_RAM_BASE, buff, len);

    MBOX_R_CTRL_0_REG = id | (len << 8) | MBOX_FULL_BIT | MBOX_INTR_BIT;

    return len;
}
