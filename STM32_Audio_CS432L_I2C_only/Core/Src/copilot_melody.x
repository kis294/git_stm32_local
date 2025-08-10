#include "stm32f4xx_hal.h"

#define CS43L22_ADDR 0x94  // 7-bit address shifted left (AD0 = 0)

// Register addresses
#define REG_BEEP_FREQ_ONTIME  0x1C
#define REG_BEEP_VOL_OFFTIME  0x1D
#define REG_BEEP_CONFIG       0x1E

// Beep configuration values
#define BEEP_SINGLE           0x01
#define BEEP_ENABLE_MASK      0x03

extern I2C_HandleTypeDef hi2c1;


void cs43l22_write(uint8_t reg, uint8_t value) {
    HAL_I2C_Mem_Write(&hi2c1, CS43L22_ADDR, reg, I2C_MEMADD_SIZE_8BIT, &value, 1, HAL_MAX_DELAY);
}

void play_note(uint8_t freq, uint8_t ontime, uint8_t volume) {
    cs43l22_write(REG_BEEP_FREQ_ONTIME, (freq << 4) | ontime);
    cs43l22_write(REG_BEEP_VOL_OFFTIME, (0x00 << 5) | volume);  // OFFTIME = 0
    cs43l22_write(REG_BEEP_CONFIG, BEEP_SINGLE);                // Trigger single beep
    HAL_Delay(500);                                             // Wait for beep to finish
    cs43l22_write(REG_BEEP_CONFIG, 0x00);                       // Clear beep
}

void play_mary_lamb() {
    // Initialization sequence (simplified)
    /*cs43l22_write(0x00, 0x99);
    cs43l22_write(0x47, 0x80);
    cs43l22_write(0x32, 0x80);
    cs43l22_write(0x32, 0x00);
    cs43l22_write(0x00, 0x00);
    cs43l22_write(0x02, 0x9E);  // Power up


    cs43l22_write(0x1D, 0x00);  // OFFTIME = 0, BPVOL = max
    cs43l22_write(0x20, 0x00);  // Left
    cs43l22_write(0x21, 0x00);  // Right
    cs43l22_write(0x22, 0x00);
    cs43l22_write(0x23, 0x00);
*/
    cs43l22_write(0x1E, 0x03);  // BEEP = single, mix enabled

    // Notes: E D C D E E E | D D D E G G
    uint8_t melody[] = {0x03, 0x02, 0x01, 0x02, 0x03, 0x03, 0x03, 0x02, 0x02, 0x02, 0x03, 0x05, 0x05};
    for (int i = 0; i < sizeof(melody); i++) {
        play_note(melody[i], 0x04, 0x10);  // ONTIME ~1.5s, Volume ~-6dB
    }
}/*
 * copilot_melody.c
 *
 *  Created on: Aug 9, 2025
 *      Author: kisho
 */


