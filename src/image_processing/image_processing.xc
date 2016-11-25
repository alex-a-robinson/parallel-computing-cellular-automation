// Image Processing
#include <stdlib.h>

#include "constants.h"
#include "image_processing.h"
#include "logic/farmer_interfaces.h"
#include "pgmIO.h"
#include "utils/utils.h" // for ceildiv
#include "utils/debug.h"

void image_reader(char filename[], client interface reader_farmer_if reader_farmer, client output_gpio_if led) {
    LOG(IFO, "[x] image_reader init\n");
    while (1) {
        select {
        case reader_farmer.start_read():
            LOG(DBG, "reader_farmer.start_read()\n");
            led.output(1);
            unsigned int dimensions[2] = {0}; //to pass into img writing c code, to get multivalue return
            // Open PGM file
            int failed_open = _openinpgm(filename, MAX_WIDTH, MAX_HEIGHT, dimensions);
            if (failed_open) {
                LOG(ERR, "Error opening %s for reading\n", filename);
                return;
            }
            unsigned int width = dimensions[0]; //unpack img data
            unsigned int height = dimensions[1];
            reader_farmer.dimensions(width, height);


            int ints_in_row = ceil_div(width, INT_SIZE);

            for (int line_index = 0; line_index < height; line_index++) {
                unsigned char line_buffer[MAX_WIDTH] = {0}; // NOTE: potentially change to int buffer so know size, also move outside for optimisation
                _readinline(line_buffer, width);

                //for(int i=0; i<width; i++) printf("%c",line_buffer[i]);

                for (int int_index = 0; int_index <= width/INT_SIZE; int_index += 1) {

                    unsigned int bit_array_buffer[INT_SIZE]={0};// NOTE: also move outside for optimisation
                    unsigned int end_of_int = ((width % INT_SIZE) && (int_index % ints_in_row == ints_in_row - 1))
                                                  ? width % INT_SIZE
                                                  : INT_SIZE;
                    for (int bit_index = 0; bit_index < end_of_int; bit_index++) {
                        bit_array_buffer[bit_index] = (line_buffer[int_index * (INT_SIZE-1) + bit_index]) ? 1:0; // TODO casting here?
                    }
                    reader_farmer.data(array_to_bits(bit_array_buffer, INT_SIZE), line_index, int_index); // NOTE: possible lock?
                }
            }

            // TODO: faster reading by putting this into the bit above
            // unsigned int array_to_bits(unsigned int array[], unsigned int n) {
            //     unsigned int bits = 0;
            //     for (unsigned int i = 0; i < n; i++) {
            //         bits |= ((array[i] ? 1 : 0) << n - i - 1); // fills from right to left
            //     }
            //     return bits;
            // }



            _closeinpgm();
            led.output(0);
            reader_farmer.read_done();
            break;
        }
    }
}

// Write pixel stream from channel c_in to PGM image file
void image_writer(char filename[], server interface farmer_writer_if farmer_writer, client output_gpio_if led) {
    LOG(IFO, "[x] image_writer init\n");
    while (1) {
        // farmer_writer.ready_for_data(); // TODO: find out how interfaces
        // handle
        // this being called repeatedly
        select {
        case farmer_writer.header(int _width, int _height):
            LOG(DBG, "farmer_writer.header(%i, %i)\n", _width, _height);
            led.output(1);
            int failed = _openoutpgm(filename, _width, _height);
            if (failed) {
                LOG(ERR, "DataOutStream: Error opening %s\n.", filename);
                return;
            }
            farmer_writer.ready_for_data();
            break;

        case farmer_writer.data(unsigned int num, unsigned int size):
            LOG(DBG, "farmer_writer.data(%u, %i)\n", num, size);
            unsigned char bitfield_array_buffer[INT_SIZE + 1] = {0}; // NOTE optimise by initialising elsewhere?
            for (int i = 0; i < INT_SIZE; i++) {
                bitfield_array_buffer[i] = (num & (1 << (INT_SIZE - i - 1))) ? (unsigned char)0xFF : (unsigned char)0;
            }
            _writeoutline(bitfield_array_buffer, size);
            farmer_writer.ready_for_data();
            break;

        case farmer_writer.end_of_data():
            LOG(IFO, "farmer_writer.end_of_data()\n");
            _closeoutpgm();
            led.output(0);
            break;
        }
    }
}
