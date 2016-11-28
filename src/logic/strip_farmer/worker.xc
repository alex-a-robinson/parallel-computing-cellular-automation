#include <platform.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "constants.h"
#include "utils/debug.h"
#include "utils/utils.h"

#include "logic/strip_farmer/worker_farmer_interface.h"
#include "logic/strip_farmer/worker.h"



// Finds neighbours, sums and returns new value
unsigned int calc_cell(unsigned int index, unsigned int strip[], unsigned int width, unsigned int ints_in_row) {
    unsigned int sum = 0; // TODO: Optimise with static indexs
    for (int r = -1; r < 2; r++) {
        unsigned int padded_width = ints_in_row * INT_SIZE;
        unsigned int row_scaler = r * padded_width + (index / padded_width) * padded_width;
        for (int c = -1; c < 2; c++) {
            unsigned int neighbour_index = ((index + c) % padded_width) % width + row_scaler;
            if (!(r == 0 && c == 0)) {
                sum += get_bit(strip, neighbour_index);
            }
        }
    }
    switch (sum) {
    case 0: // All dead, cell dies
        return 0;
    case 1: // Only one alive, cell dies
        return 0;
    case 2: // 2 alive, cell maintains
        return get_bit(strip, index);
    case 3: // 3 alive, cell born
        return 1;
    default: // more then 3, dies of overpoluation
        return 0;
    }
}

void worker(int id, server interface worker_farmer_if workers_farmer) {
    LOG(IFO, "[%i] Worker init\n", id);
    unsigned int old_strip[MAX_INTS_IN_STRIP];

    while (1) {
        select {
        case workers_farmer.tick(unsigned int strip_ref[], unsigned int first_working_row,
                                 unsigned int last_working_row, unsigned int width, unsigned int ints_in_row, int* live_cells_ptr):
            *live_cells_ptr = 0;
            memcpy(old_strip, strip_ref, MAX_INTS_IN_STRIP * sizeof(int));

            for (int int_index = first_working_row; int_index <= last_working_row; int_index++) {
                unsigned int bit_array[INT_SIZE] = {0}; // TODO take init outside, reset each loop

                unsigned int end_of_int =
                    ((width % INT_SIZE) && (int_index % ints_in_row == ints_in_row - 1)) ? width % INT_SIZE : INT_SIZE;
                for (int bit_index = 0; bit_index < end_of_int; bit_index++) {
                    int cell_index = int_index * INT_SIZE + bit_index;

                    int new_cell_state = calc_cell(cell_index, old_strip, width, ints_in_row);
                    bit_array[bit_index] = new_cell_state;
                    *live_cells_ptr += new_cell_state;

                }
                strip_ref[int_index] = array_to_bits(bit_array, INT_SIZE);
            }
            workers_farmer.tock();
            break;
        }
    }
}
