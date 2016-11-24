// Image Processing
#include <stdlib.h>

#include "constants.h"
#include "image_processing.h"
#include "logic/farmer_interfaces.h"
#include "pgmIO.h"
#include "utils/utils.h" // for ceildiv

void image_reader(char filename[], client interface reader_farmer_if reader_farmer, client output_gpio_if led) {

    while (1) {
        select {
        case reader_farmer.start_read():
            led.output(1);
            printf("DataInStream: Start...\n");
            unsigned int dimensions[2] = {0};
            // Open PGM file
            int sucessful_open = _openinpgm(filename, MAX_WIDTH, MAX_HEIGHT, dimensions);
            if (!sucessful_open) {
                printf("DataInStream: Error openening %s\n.", filename);
                return;
            }
            unsigned int width = dimensions[0];
            unsigned int height = dimensions[1];
            reader_farmer.dimensions(width, height);


            unsigned int bit_array_buffer[INT_SIZE];
            int ints_in_row = ceil_div(width, INT_SIZE);

            for (int line_index = 0; line_index < height; line_index++) {
                unsigned char line_buffer[MAX_WIDTH] = {0}; // NOTE: potentially change to int
                                                      // buffer so know size // also move outside for optimisation
                _readinline(line_buffer, width);
                // for debug  for(int i=0; i<width; i++) print line_buffer[i];
                for (int int_index = 0; int_index < width - INT_SIZE; int_index += INT_SIZE) {
                    unsigned int end_of_int = ((width % INT_SIZE) && (int_index % ints_in_row == ints_in_row - 1))
                                                  ? width % INT_SIZE
                                                  : INT_SIZE;
                    for (int bit_index = 0; bit_index < end_of_int; bit_index++) {
                        bit_array_buffer[bit_index] =
                            (int)line_buffer[int_index * INT_SIZE + bit_index]; // TODO casting here?
                    }
                    reader_farmer.data(array_to_bits(bit_array_buffer, INT_SIZE), line_index, int_index); // NOTE: possible lock?
                }
            }

            _closeinpgm();
            printf("DataInStream: Done...\n");
            led.output(0);
            reader_farmer.read_done();
            break;
        }
    }
}

// Write pixel stream from channel c_in to PGM image file
void image_writer(char filename[], server interface farmer_writer_if farmer_writer, client output_gpio_if led) {
    int width = 0;
    while (1) {
        // farmer_writer.ready_for_data(); // TODO: find out how interfaces
        // handle
        // this being called repeatedly
        select {
        case farmer_writer.header(int _width, int _height):
            led.output(1);
            width = _width;
            printf("DataOutStream: Start...\n");
            int sucessful_create = _openoutpgm(filename, _width, _height);
            if (!sucessful_create) {
                printf("DataOutStream: Error opening %s\n.", filename);
                return;
            }
            farmer_writer.ready_for_data();
            break;

        case farmer_writer.data(unsigned int num, unsigned int size):
            char bitfield_array_buffer[INT_SIZE + 1]; // NOTE optimise by initialising elsewhere?
            int_to_bitstring(num, bitfield_array_buffer);
            _writeoutline(bitfield_array_buffer, size);
            printf("DataOutStream: Line written...\n");
            farmer_writer.ready_for_data();
            break;

        case farmer_writer.end_of_data():
            _closeoutpgm();
            printf("DataOutStream: Done...\n");
            led.output(0);
            break;
        }
    }
}
