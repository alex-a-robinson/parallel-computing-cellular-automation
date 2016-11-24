#include <platform.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "constants.h"
#include "utils.xc"


unsigned int get_bit(unsigned int array[], int cell_index) {
	int int_index = cell_index / INT_SIZE;
	int shift_amount = INT_SIZE-1 - (cell_index % INT_SIZE);
	return (array[int_index] & (1 << shift_amount)) >> shift_amount;
}

// Finds neighbours, sums and returns new value
unsigned int calc_cell(unsigned int index, unsigned int strip[], unsigned int width, unsigned int ints_in_row) {
	unsigned int sum = 0;// TODO: Optimise with static indexs
	for (int r=-1; r < 2; r++) {
        unsigned int padded_width = ints_in_row * INT_SIZE;
		unsigned int row_scaler = r * padded_width + (index/padded_width)*padded_width;
		for (int c=-1; c < 2; c++) {
			unsigned int neighbour_index = ((index + c) % padded_width) % width + row_scaler;
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

int ceil_div(int a, int b) {
    return (a/b) + ((a%b)?1:0);
}

// Define interface
interface worker_farmer_if {
    [[notification]] slave void tock();
    [[clears_notification]] void tick(unsigned int strip_ref[], unsigned int first_working_row, unsigned int last_working_row, unsigned int widths, unsigned int ints_in_row);
};

void farmer(int id, client interface worker_farmer_if workers_farmer[workers], static const unsigned int workers) {
    printf("[%i] Farmer init\n", id);
    // TODO read in from image
    const int width = 32;
    const int height = 8;

    if (height % workers) {
        printf("Error: incompatible height to workers ratio\n\n");
        return;
    }
    int working_strip_height = height / workers; // TODO put in variable length strips?
    int ints_in_row = ceil_div(width, INT_SIZE);
    //TODO add availabile_workers when different


    unsigned int worker_strips[workers][MAX_INTS_IN_STRIP]={{0}};

    // TESTING
    //makes columns
    // for (int worker_id=0; worker_id<workers; worker_id++) {
    //     for (int j=0; j<MAX_INTS_IN_STRIP; j++) {
    //         worker_strips[worker_id][j] = 0x55555555;
    //         //if (worker_id == 1) worker_strips[worker_id][j] = 0x55555555;
    //         //if (worker_id == 3) worker_strips[worker_id][j] = 0x55555555;
    //     }
    //     //print_bits_array(worker_strips[worker_id], MAX_INTS_IN_STRIP);
    // }

    //makes glider
    worker_strips[0][1] = 0x04000000;
    worker_strips[0][2] = 0x02000000;
    worker_strips[1][1] = 0x0E000000;

    // //makes diagonal
    // worker_strips[0][1] = 0x0008000080;
    // worker_strips[0][2] = 0x0004000040;
    // worker_strips[1][1] = 0x0002000020;
    // worker_strips[1][2] = 0x0001000010;
    // worker_strips[2][1] = 0x0000800008;
    // worker_strips[2][2] = 0x0000400004;
    // worker_strips[3][1] = 0x0000200002;
    // worker_strips[3][2] = 0x0000100001;

    int pause = 0; // TODO update with button press
    while (!pause) {

        system("clear");
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
            workers_farmer[worker_id].tick(worker_strips[worker_id], first_working_row, last_working_row, width, ints_in_row);
        }

        int workers_done = workers;
        while (!workers_done) { // TODO: possible deadlock?
            select {
                case workers_farmer[int worker_id].tock():
                    workers_done--;
                    break;
            }
        }
    }
}

void worker(int id, server interface worker_farmer_if workers_farmer) {
    printf("[%i] Worker init\n", id);
    unsigned int old_strip[MAX_INTS_IN_STRIP];

    while (1) {
        select {
            case workers_farmer.tick(unsigned int strip_ref[], unsigned int first_working_row, unsigned int last_working_row, unsigned int width, unsigned int ints_in_row):
                memcpy(old_strip, strip_ref, MAX_INTS_IN_STRIP * sizeof(int));

                for (int int_index=first_working_row; int_index <= last_working_row; int_index++) {
                    unsigned int bit_array[INT_SIZE]={0}; //NOTE optimize by memset'ing the same memory?

                    unsigned int end_of_int = ((width % INT_SIZE) && (int_index % ints_in_row == ints_in_row-1)) ? width % INT_SIZE : INT_SIZE;
                    for (int bit_index=0; bit_index < end_of_int; bit_index++) {
                        int cell_index = int_index*INT_SIZE + bit_index;

                        bit_array[bit_index] = calc_cell(cell_index, old_strip, width, ints_in_row);
                }
                    strip_ref[int_index] = array_to_bits(bit_array, INT_SIZE);
                }

                workers_farmer.tock();
                break;
        }
    }
}

int main(void) {
    interface worker_farmer_if workers_farmer[4];

    par {
        on tile[0] : farmer(9, workers_farmer, 4);
		par (int i=0; i <4; i++)
        	on tile[0] : worker(i, workers_farmer[i]);
    }
    return 0;
}
