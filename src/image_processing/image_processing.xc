// Image Processing
#include <stdlib.h>

#include "pgmIO.h"
#include "constants.h"

// Write pixel stream from channel c_in to PGM image file
void write_image(char outfname[], chanend c_in) {
  int res;
  unsigned char line[IMWD];

  // Open PGM file
  printf("DataOutStream: Start...\n");
  res = _openoutpgm(outfname, IMWD, IMHT);
  if(res) {
    printf("DataOutStream: Error opening %s\n.", outfname);
    return;
  }

  // Compile each line of the image and write the image line-by-line
  for(int y = 0; y < IMHT; y++) {
    for(int x = 0; x < IMWD; x++) {
      c_in :> line[x];
    }
    _writeoutline(line, IMWD);
    printf("DataOutStream: Line written...\n");
  }

  // Close the PGM image
  _closeoutpgm();
  printf("DataOutStream: Done...\n");
  exit(0);
}

// Read Image from PGM file from path infname[] to channel c_out
void read_image(char infname[], chanend c_out) {
  int res;
  unsigned char line[IMWD];
  printf("DataInStream: Start...\n");

  // Open PGM file
  res = _openinpgm(infname, IMWD, IMHT);
  if(res) {
    printf("DataInStream: Error openening %s\n.", infname);
    return;
  }

  // Read image line-by-line and send byte by byte to channel c_out
  for(int y=0; y < IMHT; y++) {
    _readinline(line, IMWD);
    for(int x=0; x < IMWD; x++) {
      c_out <: line[x];
      printf("-%4.1d ", line[x]); //show image values
    }
    printf("\n");
  }

  // Close PGM image file
  _closeinpgm();
  printf("DataInStream: Done...\n");
}
