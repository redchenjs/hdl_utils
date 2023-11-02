/*
 * mailbox.h
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#ifndef INC_DRIVER_MAILBOX_H_
#define INC_DRIVER_MAILBOX_H_

#include <stdint.h>
#include <stdbool.h>

#include "drv_irq.h"

#define MBOX_IRQ_NUM    (42)
#define MBOX_RAM_SIZE   (32 * 1024)

// MAILBOX Registers
#define MBOX_INTR_BIT   (0x80000000)
#define MBOX_FULL_BIT   (0x40000000)

#define MBOX_0_CTRL_0_REG_BASE (0x40010000)
#define MBOX_0_CTRL_1_REG_BASE (0x40010004)
#define MBOX_0_DATA_0_RAM_BASE (0x40018000)

#define MBOX_1_CTRL_0_REG_BASE (0x40020000)
#define MBOX_1_CTRL_1_REG_BASE (0x40020004)
#define MBOX_1_DATA_0_RAM_BASE (0x40028000)

extern void mailbox_irq_handler(void);

#define MBOX_ENABLE_IRQ() { \
    drv_irq_register(MBOX_IRQ_NUM, mailbox_irq_handler); \
    drv_irq_enable(MBOX_IRQ_NUM); \
}

extern void mailbox_init(uint8_t core_id);

extern bool mailbox_check_acked(void);
extern bool mailbox_check_pending(void);

extern int mailbox_read_ack(uint8_t *id);
extern int mailbox_read_message(uint8_t *id, void *buff, uint32_t buff_size);

extern int mailbox_send_ack(uint8_t id);
extern int mailbox_send_message(uint8_t id, const void *buff, uint32_t len);

#endif /* INC_DRIVER_MAILBOX_H_ */
