// Controls for game
#include <stdio.h>

#include "gpio.h"
#include "i2c.h"

#include "constants.h"
#include "controls.h"
#include "logic/farmer_interfaces.h"
#include "utils/debug.h"

// Initialise and  read orientation, send first tilt event to channel
/* Orientaion control process function
 * - Sends pause/play notificaiton on interface when angle toggles over TILTED_ANGLE
 *
 * Params:
 *   client interface i2c_master_if i2c: Accelerometer interface to check
 *   client interface farmer_orientation_if farmer_orientation: Farmer interface
 *   client output_gpio_if led: LED interface to toggle on pause/play
 */
void orientation_control(client interface i2c_master_if i2c, client interface farmer_orientation_if farmer_orientation,
                         client output_gpio_if led) {
    LOG(IFO, "[x] Orientation_control init\n");

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


        if (!tilted && x > TILTED_ANGLE) { // If we are not currently tilted and over TILTED_ANGLE, pause
            tilted = 1;
            led.output(1);
            farmer_orientation.pause();
        } else if (tilted && x <= TILTED_ANGLE) { // if we are currently tilted and under TILED_ANGLE, play
            tilted = 0;
            led.output(0);
            farmer_orientation.play();
        }
    }
}

/* Button control process function
 *   - Wait for a button to press either start read or write
 *
 * Params:
 *   client interface farmer_button_if farmer_buttons: interface to farmer
 *   client input_gpio_if button_1: interface to button 1
 *   client input_gpio_if button_2: interface to button 2
 */
void button_control(client interface farmer_button_if farmer_buttons, client input_gpio_if button_1,
                    client input_gpio_if button_2) {
    LOG(IFO, "[x] button_control init\n");

    // Setup event when pins=0
    button_1.event_when_pins_eq(0);
    button_2.event_when_pins_eq(0);

    while (1) {
        select {
            // On button 1 event
            case button_1.event():
                LOG(DBG, "button_1.event()\n");
                if (button_1.input() == 0) {
                    farmer_buttons.start_read();
                    button_1.event_when_pins_eq(1);
                } else {
                    button_1.event_when_pins_eq(0);
                }
                break;

            // On button 2 event
            case button_2.event():
                LOG(DBG, "button_2.event()\n");
                if (button_2.input() == 0) {
                    farmer_buttons.start_write();
                    button_2.event_when_pins_eq(1);
                } else {
                    button_2.event_when_pins_eq(0);
                }
                break;
        }
    }
}
