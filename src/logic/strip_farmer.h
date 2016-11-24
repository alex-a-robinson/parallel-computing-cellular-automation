#ifndef STRIP_FARMER_H_
#define STRIP_FARMER_H_

#include "gpio.h"
#include "logic/farmer_interfaces.h"

unsigned int calc_cell(unsigned int index, unsigned int strip[], unsigned int width, unsigned int ints_in_row);
void worker(int id, server interface worker_farmer_if workers_farmer);
void farmer(int id, client interface worker_farmer_if workers_farmer[workers], static const unsigned int workers,
            server interface farmer_button_if farmer_buttons, client interface output_gpio_if led,
            server interface farmer_orientation_if farmer_orientation, server interface reader_farmer_if reader_farmer,
            client interface farmer_writer_if farmer_writer);

#endif
