
#include "CS43L22.h"
#include "stm32f4xx_hal.h"
#include <stdint.h>

#define I2C_ADDR 0x94

#define I2C_OK 0
#define I2C_ERR 1

extern I2C_HandleTypeDef hi2c1;
u8 i2c_set(u8 internal_addr, u8* data,u8 len) {
    // Set the I2C address and data
    // This function should implement the logic to set the I2C address and data
    // For example, it could send a start condition, send the address, send the internal address, and then send the data
    // Finally, it should send a stop condition
    // The actual implementation will depend on the specific I2C library or hardware being used
    u8 status = 0;
    status = HAL_I2C_Mem_Write(&hi2c1, I2C_ADDR, (uint16_t)internal_addr, I2C_MEMADD_SIZE_8BIT, data, len, 0xA000);
    return status;
}

u8 i2c_get(u8 internal_addr,u8* data ,u8 len) {
    int status = 0;
    status = HAL_I2C_Mem_Read(&hi2c1, I2C_ADDR, internal_addr, 0x1, data, len, 0xA000);
    return I2C_OK; // This function should return a pointer to the data read from the I2C device
}

u8 i2c_sanity()
{
    u8 data = 0x1;
    u8 status = i2c_get(I2C_ADDR, &data,1); // Read 1 byte from the I2C device at address I2C_ADDR
    if (status == I2C_OK) {
        return I2C_OK; // If the read was successful, return I2C_OK
    } else {
        return I2C_ERR; // If there was an error, return I2C_ERR
    }
}

u8 cs43l22_init_sequence()
{
    u8 stat = 0;

    u8 data = 0x00;

    data = 0x99;
    stat += i2c_set(0x00,&data,1);

    data = 0x80;
    stat += i2c_set(0x47,&data,1);

    data = 0x00;
    i2c_get(0x32,&data,1);
    data |= (0x1 << 7);
    stat += i2c_set(0x32,&data,1);

    data &=~ (0x1 << 7);
    stat += i2c_set(0x32,&data,1);

    data = 0x00;
    stat += i2c_set(0x00,&data,1);

    if(stat > 0)
    {
        //Init sequence failed
        u8 err = 1;
    }
    return stat;
}

void cs43l22_test_beep()
{
    u8 playback_control2 = 0x00;
    i2c_get(CS43L22_REG_PLAYBACK_CTL2,&playback_control2,1);
    playback_control2 &=~ ( (1<<7) | (1<<6) );
    //Disable Mute for channel A and B
    i2c_set(CS43L22_REG_PLAYBACK_CTL2,&playback_control2,1);

    //Enable HPA_VOL and HPB_VOL
    u8 vol_a = 0x00;//0dB MAX
    u8 vol_b = 0x00;//0db MAX
    i2c_set(CS43L22_REG_HP_VOL_A,&vol_a,1);
    i2c_set(CS43L22_REG_HP_VOL_B,&vol_b,1);

    //Set headphone analog gain
    u8 data = 0x00;
    u8 hdph_ana_gain = 0x6;//Gain of 1
    i2c_get(CS43L22_REG_PLAYBACK_CTL1,&data,1);
    data = data | (hdph_ana_gain<<5);
    i2c_set(CS43L22_REG_PLAYBACK_CTL1,&data,1);

    u8 beep_freq = 0x7;//1kHz beep
    u8 on_time   = 0x3;//0x3 --> 1.2 sec
    data = 0x00;
    i2c_get(CS43L22_REG_BEEP_FREQ_ONTIME,&data,1);

    data = data | (beep_freq << 3) | (on_time<<0);
    i2c_set(CS43L22_REG_BEEP_FREQ_ONTIME,&data,1);

    u8 beep_type = 0x01;//beep single
    data = 0x00;
    i2c_get(CS43L22_REG_BEEP_TONE_CONF,&data,1);

    data |= beep_type << 5;
    data &=~ (1<<5);//Enable the beep mixing
    i2c_set(CS43L22_REG_BEEP_TONE_CONF,&data,1);
}
