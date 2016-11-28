// Image Processing
#include <stdlib.h>

#include "constants.h"
#include "image_processing.h"
#include "logic/farmer_interfaces.h"
#include "pgmIO.h"
#include "utils/utils.h" // for ceildiv
#include "utils/debug.h"

/* Image reader process function
 * - Waits until asked to read an image
 * - Reads line, packs into ints, sends one by one to farmer until done
 *
 * Params:
 *   char filename[]: The filename to read
 *   client interface reader_farmer_if reader_farmer: Farmer interface
 *   client output_gpio_if led: interface to correct led to use
 */
void image_reader(char filename[], client interface reader_farmer_if reader_farmer, client output_gpio_if led) {
    LOG(IFO, "[x] image_reader init\n");

    while (1) {
        select {
            // When farmer asks to start read
            case reader_farmer.start_read():
                LOG(DBG, "reader_farmer.start_read()\n");

                // Set led on
                led.output(1);

                // Open PGM file, send array to fill with dimensions data
                unsigned int dimensions[2] = {0};
                int failed_open = _openinpgm(filename, MAX_WIDTH, MAX_HEIGHT, dimensions);
                if (failed_open) {
                    LOG(ERR, "Error opening %s for reading\n", filename);
                    return;
                }

                // Unpack dimensions, send to farmer
                unsigned int width = dimensions[0];
                unsigned int height = dimensions[1];
                reader_farmer.dimensions(width, height);

                // Calculate to use for padding
                int ints_in_row = ceil_div(width, INT_SIZE);

                // For each line
                for (int line_index = 0; line_index < height; line_index++) {
                    // Initilise a buffer to read the line into, read a line
                    unsigned char line_buffer[MAX_WIDTH] = {0};
                    _readinline(line_buffer, width);

                    // For each int in the line, pack values into ints
                    for (int int_index = 0; int_index <= width/INT_SIZE; int_index += 1) {
                        // Initilise an int to pack into
                        unsigned int int_buffer = 0;

                        // Calculate the bit index the int ends at, used for padding
                        unsigned int end_of_int = ((width % INT_SIZE) && (int_index % ints_in_row == ints_in_row - 1))
                                                      ? width % INT_SIZE
                                                      : INT_SIZE;

                        // For each bit, pack value from line buffer into our int buffer
                        for (int bit_index = 0; bit_index < end_of_int; bit_index++) {
                            int cell_val =  (line_buffer[int_index * (INT_SIZE-1) + bit_index]) ? 1:0;
                            int_buffer |= (cell_val << INT_SIZE - bit_index - 1);
                        }

                        // Send the int to farmer
                        reader_farmer.data(int_buffer, line_index, int_index);
                    }
                }

                // On completion of read, close the file, turn off the led, notify farmer
                _closeinpgm();
                led.output(0);
                reader_farmer.read_done();
                break;
        }
    }
}

// Write pixel stream from channel c_in to PGM image file
/* Image writer process
 * - Wait for farmer tell us the file header, then each line of data until done
 *
 * Params:
 *   char filename[]: The filename to write to
 *   server interface farmer_writer_if farmer_writer: The farmer interface
 *   client output_gpio_if led: The led interface to light
 */
void image_writer(char filename[], server interface farmer_writer_if farmer_writer, client output_gpio_if led) {
    LOG(IFO, "[x] image_writer init\n");

    while (1) {
        select {
            // When we get the header from the farmer, light led, open file, and write header
            case farmer_writer.header(int _width, int _height):
                LOG(DBG, "farmer_writer.header(%i, %i)\n", _width, _height);

                // Light LED
                led.output(1);

                // Open file, NOTE: header is written here
                int failed = _openoutpgm(filename, _width, _height);
                if (failed) {
                    LOG(ERR, "DataOutStream: Error opening %s\n.", filename);
                    return;
                }

                // Notify farmer ready for data to be written
                farmer_writer.ready_for_data();
                break;

            // When we get data from farmer, unpack and write
            case farmer_writer.data(unsigned int num, unsigned int size):
                LOG(DBG, "farmer_writer.data(%u, %i)\n", num, size);

                // Initilise an array to hold unpacked values from our int
                unsigned char bitfield_array_buffer[INT_SIZE + 1] = {0};

                // For bit in the int, unpack into our array
                // NOTE we don't mind about padding as we get the number of bits to write from size
                for (int i = 0; i < INT_SIZE; i++) {
                    bitfield_array_buffer[i] = (num & (1 << (INT_SIZE - i - 1))) ? (unsigned char)0xFF : (unsigned char)0;
                }

                // Write our array of valus to the file
                _writeoutline(bitfield_array_buffer, size);

                // Notify farmer we are ready for more data
                farmer_writer.ready_for_data();
                break;

            // When we get end of data, close file and turn off LED
            case farmer_writer.end_of_data():
                LOG(IFO, "farmer_writer.end_of_data()\n");
                _closeoutpgm();
                led.output(0);
                break;
        }
    }
}
