#ifndef STRIP_FARMER_WORKER_H_
#define STRIP_FARMER_WORKER_H_

#include "gpio.h"
#include "logic/strip_farmer/worker_farmer_interface.h"

unsigned int calc_cell(unsigned int index, unsigned int strip[], unsigned int width, unsigned int ints_in_row);
void worker(int id, server interface worker_farmer_if workers_farmer);

#endif
