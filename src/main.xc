// Main program

#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include <string.h>
#include "gpio.h"
#include "i2c.h"
#include "image_processing.h"
#include "controls.h"
#include "constants.h"
#include <stdlib.h>

// Interface ports to orientation
on tile[0] : port p_scl = XS1_PORT_1E;
on tile[0] : port p_sda = XS1_PORT_1F;

// GPIO port declarations
on tile[0] : in port explorer_buttons = XS1_PORT_4E;
on tile[0] : out port explorer_leds = XS1_PORT_4F;

/* Start your implementation by changing this function to implement the game of life
 * by farming out parts of the image to worker threads who implement it...
 * Currently the function just inverts the image
*/
void distributor(chanend c_in, chanend c_out, chanend fromAcc) {
  unsigned char val;

  // Starting up and wait for tilting of the xCore-200 Explorer
  printf("ProcessImage: Start, size = %dx%d\n", IMHT, IMWD);
  printf("Waiting for Board Tilt...\n");
  fromAcc :> int value;

  // Read in and do something with your image values..
  // This just inverts every pixel, but you should
  // change the image according to the "Game of Life"
  printf("Processing...\n");
  for(int y=0; y < IMHT; y++) {   // go through all lines
    for(int x=0; x < IMWD; x++) { // go through each pixel per line
      c_in :> val;                  // read the pixel value
      c_out <: (unsigned char)(val ^ 0xFF); // send some modified pixel out
    }
  }
  printf("\nOne processing round completed...\n");
}

// Orchestrate concurrent system and start up all threads
int main(void) {
    i2c_master_if i2c[1];               //interface to orientation
    chan c_inIO, c_outIO, c_control;    //extend your channel definitions here

    input_gpio_if i_explorer_buttons[2];
    output_gpio_if i_explorer_leds[4];

    par {
        on tile[0] : i2c_master(i2c, 1, p_scl, p_sda, 10);   //server thread providing orientation data
        on tile[0] : orientation_control(i2c[0], c_control);          //client thread reading orientation data
        on tile[0] : DataInStream("images/test.pgm", c_inIO);          //thread to read in a PGM image
        on tile[0] : DataOutStream("images/testout.pgm", c_outIO);       //thread to write out a PGM image
        on tile[0] : distributor(c_inIO, c_outIO, c_control);//thread to coordinate work on image
        on tile[0] : input_gpio_with_events(i_explorer_buttons, 2, explorer_buttons, null);
        on tile[0] : output_gpio(i_explorer_leds, 4, explorer_leds, null);
        on tile[0] : button_control(i_explorer_buttons[0], i_explorer_buttons[1],
                             i_explorer_leds[0], i_explorer_leds[1],
                             i_explorer_leds[2], i_explorer_leds[3]);
    }

    return 0;
}
