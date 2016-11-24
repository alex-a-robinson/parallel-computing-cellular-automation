#ifndef STRIP_FARMER_H_
#define STRIP_FARMER_H_

uint calc_cell(uint index, uint strip[], uint width, uint ints_in_row);
void worker(int id, server interface worker_farmer_if workers_farmer);
void farmer(int id, client interface worker_farmer_if workers_farmer[workers],
            static const uint workers,
            server interface farmer_button_if farmer_button,
            client interface output_gpio_if led);

#endif
