#include <platform.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <xs1.h>

#include "gpio.h"
#include "i2c.h"

#include "constants.h"
#include "controls/controls.h"
#include "image_processing/image_processing.h"

#include "logic/farmer_interfaces.h"
#include "logic/strip_farmer/worker.h"
#include "logic/strip_farmer/farmer.h"
#include "logic/strip_farmer/worker_farmer_interface.h"

#include "utils/debug.h"

// Interface ports to orientation
on tile[0] : port p_scl = XS1_PORT_1E;
on tile[0] : port p_sda = XS1_PORT_1F;

// GPIO port declarations
on tile[0] : in port explorer_buttons = XS1_PORT_4E;
on tile[0] : out port explorer_leds = XS1_PORT_4F;

int main(void) {

    // Orientation interface
    i2c_master_if i2c[1];

    // Buttons & LEDs
    input_gpio_if i_explorer_buttons[2];
    output_gpio_if i_explorer_leds[4]; // 0 = GREEN, 1 = RGB_BLUE, 2 = RGB_GREEN, 3 = RGB_RED

    // Farmer interfaces between controls and workers
    interface worker_farmer_if workers_farmer[MAX_WORKERS];
    interface farmer_button_if farmer_buttons;
    interface reader_farmer_if reader_farmer;
    interface farmer_writer_if farmer_writer;
    interface farmer_orientation_if farmer_orientation;

    par {
        // IO cores
        on tile[0] : i2c_master(i2c, 1, p_scl, p_sda, 10);                                  // provides orientation data
        on tile[0] : input_gpio_with_events(i_explorer_buttons, 2, explorer_buttons, null); // provides button data
        on tile[0] : output_gpio(i_explorer_leds, 4, explorer_leds, null);                  // provides led output

        // Control cores
        on tile[0] : orientation_control(i2c[0], farmer_orientation, i_explorer_leds[3]);
        on tile[0] : button_control(farmer_buttons, i_explorer_buttons[0], i_explorer_buttons[1]);

        // Reader/Writer cores
        // NOTE: combine onto single core later?
        on tile[0] : image_reader(INPUT_FILENAME, reader_farmer, i_explorer_leds[2]);
        on tile[0] : image_writer(OUTPUT_FILENAME, farmer_writer, i_explorer_leds[1]);

        // Farmer core
        on tile[1] : farmer(9, workers_farmer, MAX_WORKERS, farmer_buttons, i_explorer_leds[0], farmer_orientation,
                            reader_farmer, farmer_writer);

        // Workers cores
        par(int i = 0; i < MAX_WORKERS; i++) { on tile[1] : worker(i, workers_farmer[i]); }
    }

    return 0;
}
