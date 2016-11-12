// Controls for game
#include <stdio.h>
#include "i2c.h"
#include "constants.h"
#include "gpio.h"

// Initialise and  read orientation, send first tilt event to channel
void orientation_control(client interface i2c_master_if i2c,
                         chanend toDist) {
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
            // TODO light RED LED
            toDist <: 1;
        } else if (tilted) {
            tilted = 0;
            // TODO ZERO RED LED
        }
    }
}

void button_control(client input_gpio_if button_1, client input_gpio_if button_2,
          client output_gpio_if led_green, client output_gpio_if rgb_led_blue,
          client output_gpio_if rgb_led_green, client output_gpio_if rgb_led_red) {

    button_1.event_when_pins_eq(0);
    button_2.event_when_pins_eq(0);

    while (1) {
        select {
            case button_1.event(): // Start image read
                if (button_1.input() == 0) {
                    printf("Start image read\n");
                    // TODO: Tell read thread to read in
                    rgb_led_green.output(1);
                    // TODO: untoggle this LED when read done
                    button_1.event_when_pins_eq(1); // Set button event state to active high for debounce
                } else {
                    button_1.event_when_pins_eq(0);
                }
                break;

            case button_2.event(): // Start image write
                if (button_2.input() == 0) {
                    printf("Start image write\n");
                    // TODO: Tell write thread to write out
                    rgb_led_blue.output(1);
                    // TODO: untoggle this LED when write done
                    button_2.event_when_pins_eq(1); // Set button event state to active high for debounce
                } else {
                    button_2.event_when_pins_eq(0);
                }
                break;

            // TODO: Flash  green LED each tick
        }
    }
}
