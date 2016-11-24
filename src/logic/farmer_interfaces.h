#ifndef FARMER_INTERFACES_H_
#define FARMER_INTERFACES_H_

#include "gpio.h"

interface worker_farmer_if {
    [[notification]] slave void tock();
    [[clears_notification]] void tick(unsigned int strip_ref[], unsigned int first_working_row,
                                      unsigned int last_working_row, unsigned int widths, unsigned int ints_in_row);
};

interface farmer_button_if {
    void start_read();
    [[guarded]] void start_write();
};

interface reader_farmer_if { // GREEN LED
    [[notification]] slave void start_read();
    void dimensions(unsigned int width, unsigned int height);
    void data(unsigned int num, int row_index, int int_index);
    [[clears_notification]] void read_done();
};

interface farmer_writer_if { // BLUE LED
    void header(int width, int height);
    [[notification]] slave void ready_for_data();
    [clears_notification]] void data(unsigned int num, unsigned int size);
    [void end_of_data();
};

interface farmer_orientation_if { // RED LED
    [[guarded]] void pause();
    [[guarded]] void play();
};

#endif
