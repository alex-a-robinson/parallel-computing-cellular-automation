// Controls for game
#include <stdio.h>

#include "i2c.h"
#include "gpio.h"

#include "constants.h"
#include "logic/strip_farmer_interfaces.h";

// Initialise and  read orientation, send first tilt event to channel
void orientation_control(client interface i2c_master_if i2c,
                         client interface farmer_orientation_control foc,
                         client output_gpio_if led) {
    i2c_regop_res_t result;
    char status_data = 0;
    int tilted = 0;

    // Configure FXOS8700EQ
    result = i2c.write_reg(FXOS8700EQ_I2C_ADDR, FXOS8700EQ_XYZ_DATA_CFG_REG, 0x01);
    if (result != I2C_REGOP_SUCCESS) {
        printf("I2C write reg failed\n");
    }

    // Enable FXOS8700EQ
    result = i2c.write_reg(FXOS8700EQ_I2C_ADDR, FXOS8700EQ_CTRL_REG_1, 0x01);
    if (result != I2C_REGOP_SUCCESS) {
        printf("I2C write reg failed\n");
    }

    // Probe the orientation x-axis forever
    while (1) {
        // Check until new orientation data is available
        do {
            status_data = i2c.read_reg(FXOS8700EQ_I2C_ADDR, FXOS8700EQ_DR_STATUS, result);
        } while (!status_data & 0x08);

        // Get new x-axis tilt value
        int x = read_acceleration(i2c, FXOS8700EQ_OUT_X_MSB);

        if (!tilted && x > TILTED_ANGLE) {
            tilted = 1;
            led.output(1);
            foc.pause();
        } else if (tilted && x <= TILTED_ANGLE) {
            tilted = 0;
            led.output(0);
            foc.play();
        }
    }
}



void button_control(client interface farmer_button_control fbc,
                    client input_gpio_if button_1, client input_gpio_if button_2) {
    button_1.event_when_pins_eq(0);
    button_2.event_when_pins_eq(0);

    while (1) {
        select {
            case button_1.event(): // Start image read
                if (button_1.input() == 0) {
                    fbc.start_read();
                    button_1.event_when_pins_eq(1);
                } else {
                    button_1.event_when_pins_eq(0);
                }
            case button_2.event(): // Start image write
                if (button_2.input() == 0) {
                    fbc.start_write();
                    button_2.event_when_pins_eq(1);
                } else {
                    button_2.event_when_pins_eq(0);
                }
        }
}
