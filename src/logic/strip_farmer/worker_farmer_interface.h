#ifndef WORKER_FARMER_INTERFACE_H_
#define WORKER_FARMER_INTERFACE_H_

#include "gpio.h"

interface worker_farmer_if {
    [[notification]] slave void tock();
    [[clears_notification]] void tick(unsigned int strip_ref[], unsigned int first_working_row,
                                      unsigned int last_working_row, unsigned int widths, unsigned int ints_in_row, int* live_cells);
};

#endif
