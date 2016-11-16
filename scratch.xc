#include <platform.h>
#include <stdio.h>
#include <string.h>

#include "constants.h"
#include "utils.xc"
//#include "utils/utils.h"


unsigned int get_bit(unsigned int array[], int index) {
	int array_index = index / INT_SIZE;
	int rel_index = index % INT_SIZE;
	int shift_amount = INT_SIZE - rel_index-1;
	return (array[array_index] & (1 << shift_amount)) >> shift_amount;
}



// Finds neighbours, sums and returns new value
uint calc_cell(uint index, uint strip[], uint width) {
	uint sum = 0;

	// TODO: Opptimise with static indexs
	for (int r=-1; r < 2; r++) {
		uint row_scaler = (index / width + r) * width;
		for (int c=-1; c < 2; c++) {
			uint neighbour_index = ((index + c) % width + row_scaler);
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
interface worker_farmer {
    [[guarded]] [[clears_notification]] void init_strip(int start_index, int number_of_cells, int width, int height);
    [[notification]] slave void tock();
    [[guarded]] void tick(unsigned int strip_ref[], uint first_working_row, uint last_working_row, uint widths, uint ints_in_row);
};

void farmer(int id, client interface worker_farmer wf_i[workers], static const uint workers) {
    printf("[%i] Farmer init\n", id);
    // TODO read in from image
    const int width = 16;
    const int height = 8;

    if (height % workers) {
        printf("Error: incompatible height to workers ratio\n\n");
        return;
    }
    int working_strip_height = height / workers; // TODO put in variable length strips?
    //int number_of_cells = working_strip_height * width;
    int ints_in_row = ceil_div(width, INT_SIZE);
    //int ints_in_strip = (working_strip_height+2)*ints_in_row;
    //TODO add availabile_workers when different


    uint worker_strips[workers][MAX_INTS_IN_STRIP]={{0}};

    //NOTE arrays used for testing, will be image input later


    // //makes columns
    // for (int worker_id=0; worker_id<workers; worker_id++) {
    //     for (int j=0; j<MAX_INTS_IN_STRIP; j++) {
    //         worker_strips[worker_id][j] = 0x55555555;
    //         //if (worker_id == 1) worker_strips[worker_id][j] = 0x55555555;
    //         //if (worker_id == 3) worker_strips[worker_id][j] = 0x55555555;
    //     }
    //     //print_bits_array(worker_strips[worker_id], MAX_INTS_IN_STRIP);
    // }

    // //makes glider
    // worker_strips[0][1] = 0x00400000;
    // worker_strips[0][2] = 0x00200000;
    // worker_strips[1][1] = 0x00E00000;

    //makes diagonal
    worker_strips[0][1] = 0x00008000;
    worker_strips[0][2] = 0x00004000;
    worker_strips[1][1] = 0x00002000;
    worker_strips[1][2] = 0x00001000;
    worker_strips[2][1] = 0x00000800;
    worker_strips[2][2] = 0x00000400;
    worker_strips[3][1] = 0x00000200;
    worker_strips[3][2] = 0x00000100;

    int pause = 0; // TODO update with button press
    while (!pause) {

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
            printf("[%i] tick, ", worker_id);
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
        printf("all workers done.\n");
    }
}

void worker(int id, server interface worker_farmer wf_i) {
    printf("[%i] Worker init\n", id);
    uint old_strip[MAX_INTS_IN_STRIP];

    // Work on each tick
    while (1) {
        select {
            case wf_i.tick(unsigned int strip_ref[], uint first_working_row, uint last_working_row, uint width, uint ints_in_row):

                memcpy(old_strip, strip_ref, MAX_INTS_IN_STRIP * sizeof(int));

                //print_bits_array(old_strip, MAX_INTS_IN_STRIP);

                for (int int_index=first_working_row; int_index <= last_working_row; int_index++) {
                    uint bit_array[INT_SIZE]={0}; //NOTE optimize by memset'ing the same memory?

                    uint end_of_int = ((width % INT_SIZE) && (int_index % ints_in_row == ints_in_row-1)) ? width % INT_SIZE : INT_SIZE;

                    for (int bit_index=0; bit_index < end_of_int; bit_index++) {
                        int cell_index = int_index*INT_SIZE + bit_index;
                        bit_array[bit_index] = calc_cell(cell_index, old_strip, width);
                    }
                    strip_ref[int_index] = array_to_bits(bit_array, INT_SIZE);
                }
//TODO
//side wrapping (edge glider
//width < 32  disapear

                //
                // for (int row=first_working_row; row < last_working_row; row++) {
                //     for (int int_index=0; int_index < ints_in_row; int_index++) {
                //         uint bit_array[INT_SIZE]={0}; //NOTE: optimize by memset'ing the same memory?
                //
                //         for (int bit_index=0; bit_index < INT_SIZE; bit_index++) {
                //             if (int_index*INT_SIZE + bit_index >= width) break;
                //             int cell_index = row*width + int_index*INT_SIZE + bit_index;
                //             bit_array[bit_index] = calc_cell(cell_index, old_strip, width);
                //         }
                //
                //         strip_ref[row*ints_in_row + int_index] = array_to_bits(bit_array, INT_SIZE);
                //     }
                // }

                //memcpy(strip_ref, old_strip, MAX_INTS_IN_STRIP * sizeof(int));



                printf("[%i] tock, ", id);
                wf_i.tock();
                break;
        }
    }
}

int main(void) {
    interface worker_farmer wf_i[4];

    par {
        on tile[0] : farmer(9, wf_i, 4);
        on tile[0] : worker(0, wf_i[0]);
        on tile[0] : worker(1, wf_i[1]);
        on tile[0] : worker(2, wf_i[2]);
        on tile[0] : worker(3, wf_i[3]);
    }
    return 0;
}
