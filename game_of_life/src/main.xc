// Main program

#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include "i2c.h"
#include "image_processing.h"
#include "controls.h"
#include "constants.h"

// Interface ports to orientation
port p_scl = XS1_PORT_1E;
port p_sda = XS1_PORT_1F;

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

char infname[] = "test.pgm";     //put your input image path here
char outfname[] = "testout.pgm"; //put your output image path here
chan c_inIO, c_outIO, c_control;    //extend your channel definitions here

par {
    i2c_master(i2c, 1, p_scl, p_sda, 10);   //server thread providing orientation data
    orientation(i2c[0],c_control);          //client thread reading orientation data
    DataInStream(infname, c_inIO);          //thread to read in a PGM image
    DataOutStream(outfname, c_outIO);       //thread to write out a PGM image
    distributor(c_inIO, c_outIO, c_control);//thread to coordinate work on image
  }

  return 0;
}
