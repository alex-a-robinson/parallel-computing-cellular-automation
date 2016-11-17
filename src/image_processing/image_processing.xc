// Image Processing
#include <stdlib.h>

#include "pgmIO.h"
#include "constants.h"

void read_image(char filename[], client interface read_image_farmer rif,  client output_gpio_if led) {

    while(1) {
        select{
            case rif.start_read():
                led.output(1);
                printf("DataInStream: Start...\n");

                // Open PGM file
                int {width,height} = _openinpgm(filename, MAX_WIDTH, MAX_HEIGHT);
                if(!(width && height)) {
                    printf("DataInStream: Error openening %s\n.", filename);
                    return;
                }
                rif.dimensions(width, height);


                unsigned char line_buffer[MAX_WIDTH]; //NOTE: potentially change to int buffer so know size
                unsigned int bit_array_buffer[INT_SIZE];
                int ints_in_row = ceil_div(width, INT_SIZE);

                for(int line_index=0; line_index < height; line_index++) {
                    _readinline(line_buffer, width);
                    // for debug  for(int i=0; i<width; i++) print line_buffer[i];
                    for(int int_index = 0; int_index < width-INT_SIZE; int_index += INT_SIZE) {
                        uint end_of_int = ((width % INT_SIZE) && (int_index % ints_in_row == ints_in_row-1)) ? width % INT_SIZE : INT_SIZE;
                        for (int bit_index=0; bit_index < end_of_int; bit_index++) {
                            bit_array_buffer[bit_index] = (int) line_buffer[int_index*INT_SIZE + bit_index]; //TODO casting here?
                        }
                        rif.data(array_to_bits(bit_array_buffer, INT_SIZE);
                    }
                }

                _closeinpgm();
                printf("DataInStream: Done...\n");
                led.output(0);
                rif.read_done();
                break;

    }
}

// Write pixel stream from channel c_in to PGM image file
void write_image(char filename[], client interface farmer_write_image fwi, client output_gpio_if led) {
    int led_status = 0;
    fwi.ready_for_data(); //NOTE: multiple images, change here
    while(1) {
        //fwi.ready_for_data(); // TODO: find out how interfaces handle this being called repeatedly
    switch {
        case fwi.data(int data):
            if (!led_status) { //prevents multiple calls
                led_status = 1;
                led.output(1);

            unsigned char line[width];

            // Open PGM file
            printf("DataOutStream: Start...\n");
            int res = _openoutpgm(outfname, width, height);
            if(res) {
                printf("DataOutStream: Error opening %s\n.", outfname);
                return;
            }

          // Compile each line of the image and write the image line-by-line
          for(int y = 0; y < height; y++) {
            for(int x = 0; x < width; x++) {
              c_in :> line[x];
            }
            _writeoutline(line, width);
            printf("DataOutStream: Line written...\n");
          }

          // Close the PGM image
          _closeoutpgm();
          printf("DataOutStream: Done...\n");


              fwi.ready_for_data();
          case end_of_data():
              led_status = 0;
              led.output(0)
      }
  }


}
