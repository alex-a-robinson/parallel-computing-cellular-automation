#include <platform.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "constants.h"
#include "utils/debug.h"
#include "utils/utils.h"

#include "logic/strip_farmer/worker_farmer_interface.h"
#include "logic/strip_farmer/worker.h"

/* Calculates the result a cell should have
 * Params:
 *   unsigned int index: Grid index of the cell
 *   unsinged int strip[]: Strip array
 *   unsigned int width: Width of the grid
 *   unsinged int ints_in_row: Number of ints in each row
 */
unsigned int calc_cell(unsigned int index, unsigned int strip[], unsigned int width, unsigned int ints_in_row) {
    unsigned int sum = 0;

    // For each row relative to index
    // NOTE: Can be optimised with static indexs
    for (int r = -1; r < 2; r++) {
        // Calc scaler values
        unsigned int padded_width = ints_in_row * INT_SIZE;
        unsigned int row_scaler = r * padded_width + (index / padded_width) * padded_width;

        // For each column relatve to index
        for (int c = -1; c < 2; c++) {
            // Calc the grid index of the neighbour, add its value to the sum unless its the centre cell
            unsigned int neighbour_index = ((index + c) % padded_width) % width + row_scaler;
            if (!(r == 0 && c == 0)) {
                sum += get_bit(strip, neighbour_index);
            }
        }
    }

    // Game of life rules
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

/* Worker process function
 * - Gets strip from farmer, works until completion, waits
 * Params:
 *   int id: ID of the worker
 *   server interface worker_farmer_if workers_farmer: farmer interface
 */
void worker(int id, server interface worker_farmer_if workers_farmer) {
    LOG(IFO, "[%i] Worker init\n", id);

    // Initiate a local strip to work on, avoiding working on the strip we are updating
    unsigned int old_strip[MAX_INTS_IN_STRIP];

    while (1) {
        select {
            case workers_farmer.tick(unsigned int strip_ref[], unsigned int first_working_row,
                                     unsigned int last_working_row, unsigned int width, unsigned int ints_in_row, int* live_cells_ptr):
                // Copy into a local strip
                memcpy(old_strip, strip_ref, MAX_INTS_IN_STRIP * sizeof(int));

                *live_cells_ptr = 0; // The nuber of cells alive (for stats), calc in loops bellow

                // For each int we need to work on
                for (int int_index = first_working_row; int_index <= last_working_row; int_index++) {

                    // Calc the bit index of last cell in the int (this changes if there is padding on the int or not)
                    unsigned int end_of_int = ((width % INT_SIZE) && (int_index % ints_in_row == ints_in_row - 1)) ? width % INT_SIZE : INT_SIZE;

                    // For each bit in the int, calc the new value to the cell
                    unsigned int bit_array[INT_SIZE] = {0}; // array which we will convert to an int
                    for (int bit_index = 0; bit_index < end_of_int; bit_index++) {
                        int cell_index = int_index * INT_SIZE + bit_index; // index, scaled up to int, then bit

                        // Calc the new state, push into the bit array, update the live cells count
                        int new_cell_state = calc_cell(cell_index, old_strip, width, ints_in_row);
                        bit_array[bit_index] = new_cell_state;
                        *live_cells_ptr += new_cell_state;

                    }

                    // Update the strip with the cells we just calculated
                    strip_ref[int_index] = array_to_bits(bit_array, INT_SIZE);
                }

                // Tell farmer we are done with this tick
                workers_farmer.tock();
                break;
        }
    }
}
