#include <platform.h>
#include <stdio.h>
#include <string.h>

//#include "constants.h"
#include "utils.xc"

int ceil_div(int a, int b) {
    return (a/b) + ((a%b)?1:0);
}

// Define interface
interface worker_farmer {
    [[guarded]] [[clears_notification]] void init_strip(int start_index, int number_of_cells, int width, int height);
    [[notification]] slave void tock();
    [[guarded]] void tick(int strip_ref[], int start_index, int number_of_cells, int width, int height);
};

void farmer(int id, client interface worker_farmer wf_i[available_workers], static const uint available_workers) {
    printf("[%i] Farmer init\n", id);
    const int width = 64;
    const int height = 8;
    if (height % available_workers) {
        printf("Error: incompatible height to workers ratio\n\n");
        return;
    }
    const int strip_height = height / available_workers; // TODO put in variable length strips?
    //const int number_of_cells = strip_height * width;
    const int ints_in_row = ceil_div(width, INT_SIZE);
    const ints_in_whole_strip = (strip_height+2)*ints_in_row;
    //const int workers_required = ceil_div(height, strip_height); //TODO add availabile when different

    const int index_of_first_working_row = ints_in_row;
    const int index_of_last_working_row = ints_in_row * strip_height;
    const int index_of_bottom_overlap_row = ints_in_row * (strip_height + 1);


    //4 workers, stripsize 2,

    uint worker_strips[available_workers][10]; // TODO Optimise for memory
    // TODO initilise worker_strip from image reading channel
        // using arrays for testing for now
    for (int worker_id=0; worker_id<available_workers; worker_id++) {
        for (int j=0; j<ints_in_whole_strip; j++) {
            worker_strips[worker_id][j] = 0;
        }
    }

    for (int j=0; j<ints_in_whole_strip; j++) {
        worker_strips[1][j] = 0x55555555;
        worker_strips[3][j] = 0xaaaaaaaa;
    }


    for (int worker_id=0; worker_id<available_workers; worker_id++) {
        print_bits_array(worker_strips[worker_id], 10);
    }
    printf("-------------\n");


    int pause = 0; // TODO update with button press

    while (!pause) {
        // TODO: Recalculate strips - neightbour
        // TODO: calculate strip stats

        for (int worker_id=0; worker_id < available_workers; worker_id++) {
            // TODO: calc strip sizes
            int previous_worker_id = (worker_id-1) % available_workers;
            int next_worker_id = (worker_id+1) % available_workers;

            // First overlap
            memcpy(worker_strips[worker_id], &(worker_strips[previous_worker_id][index_of_last_working_row]), ints_in_row * sizeof(int));

            // Final overlap
            memcpy(&(worker_strips[worker_id][index_of_bottom_overlap_row]), &(worker_strips[next_worker_id][index_of_first_working_row]), ints_in_row * sizeof(int));

            //TODO: fix  wf_i[worker_id].tick(worker_strips[worker_id], start_index, number_of_cells, width, height);
            printf("%i, %i, %i\n", worker_id, 1, 1);
            print_bits_array(worker_strips[worker_id], 10);
            //print_bits(worker_strips[worker_id][0]);
        }

        pause = 1;

        int workers_done = available_workers;
        while (!workers_done) { // TODO: possible deadlock?
            select {
                case wf_i[int worker_id].tock():
                    workers_done--;
                    break;
            }
        }
    }
}

void worker(int id, server interface worker_farmer wf_i) {
    printf("[%i] Worker init\n", id);

    // Work on each tick
    while (1) {
        select {
            case wf_i.tick(int ref[], int start_index, int number_of_cells, int width, int height):
                // TODO: work
                printf("[%i] tick done\n", id);
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
