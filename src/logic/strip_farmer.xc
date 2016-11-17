#include <platform.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "constants.h"
#include "utils/utils.h"
#include "utils/debug.h"

#include "logic/farmer_interfaces.h"
#include "logic/strip_farmer.h"


#include "utils.xc" // DEBUGING


// Finds neighbours, sums and returns new value
uint calc_cell(uint index, uint strip[], uint width, uint ints_in_row) {
	uint sum = 0;// TODO: Optimise with static indexs
	for (int r=-1; r < 2; r++) {
        uint padded_width = ints_in_row * INT_SIZE;
		uint row_scaler = r * padded_width + (index/padded_width)*padded_width;
		for (int c=-1; c < 2; c++) {
			uint neighbour_index = ((index + c) % padded_width) % width + row_scaler;
			if (!(r == 0 && c == 0)) {
				sum += get_bit(strip, neighbour_index);
			}
		}
	}
	switch(sum) {
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


void worker(int id, server interface worker_farmer wf_i) {
    LOG(IFO, "[%i] Worker init\n", id);
    uint old_strip[MAX_INTS_IN_STRIP];

    while (1) {
        select {
            case wf_i.tick(unsigned int strip_ref[], uint first_working_row, uint last_working_row, uint width, uint ints_in_row):
                memcpy(old_strip, strip_ref, MAX_INTS_IN_STRIP * sizeof(int));

                for (int int_index=first_working_row; int_index <= last_working_row; int_index++) {
                    uint bit_array[INT_SIZE]={0}; //TODO take init outside, reset each loop

                    uint end_of_int = ((width % INT_SIZE) && (int_index % ints_in_row == ints_in_row-1)) ? width % INT_SIZE : INT_SIZE;
                    for (int bit_index=0; bit_index < end_of_int; bit_index++) {
                        int cell_index = int_index*INT_SIZE + bit_index;

                        bit_array[bit_index] = calc_cell(cell_index, old_strip, width, ints_in_row);
                }
                    strip_ref[int_index] = array_to_bits(bit_array, INT_SIZE);
                }

                wf_i.tock();
                break;
        }
    }
}

void farmer(int id, client interface worker_farmer wf_i[workers], static const uint workers,
			server interface farmer_button fb, client output_gpio_if led) {
    LOG(IFO, "[%i] Farmer init\n", id);
    // TODO read in from image
    const int width = 32;
    const int height = 8;

	int tick = 0;

    if (height % workers) {
        LOG(ERR, "Error: incompatible height to workers ratio\n\n");
        return;
    }
    int working_strip_height = height / workers; // TODO put in variable length strips?
    int ints_in_row = ceil_div(width, INT_SIZE);
    //TODO add availabile_workers when different

    uint worker_strips[workers][MAX_INTS_IN_STRIP]={{0}};

	// TODO Read in from interface

    int pause = 0; // TODO update with button press
    while (!pause) {

        // system("clear"); DEBUG
        print_strips_as_grid(worker_strips, working_strip_height, workers, ints_in_row);

        // TODO: calculate strip stats

        int top_overlap_row = 0;
        int first_working_row = ints_in_row;
        int last_working_row = ints_in_row * working_strip_height;
        int bottom_overlap_row = ints_in_row * (working_strip_height + 1);

        //update neighboring overlaps
        for (int worker_id=0; worker_id < workers; worker_id++) {
            int previous_worker_id = (worker_id-1) % workers;
            int next_worker_id = (worker_id+1) % workers;
            memcpy(&(worker_strips[worker_id][top_overlap_row]), &(worker_strips[previous_worker_id][last_working_row]), ints_in_row * sizeof(int));
            memcpy(&(worker_strips[worker_id][bottom_overlap_row]), &(worker_strips[next_worker_id][first_working_row]), ints_in_row * sizeof(int));
        }

        for (int worker_id=0; worker_id < workers; worker_id++) {
            wf_i[worker_id].tick(worker_strips[worker_id], first_working_row, last_working_row, width, ints_in_row);
        }

        int workers_done = workers;
        while (!workers_done) { // TODO: possible deadlock?
            select {
                case wf_i[int worker_id].tock():
                    workers_done--;
                    break;
            }
        }
		tick++;
		led.output(tick % 2); // Blink LED, might not work
    }
}
