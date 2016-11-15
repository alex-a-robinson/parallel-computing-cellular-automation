#include <platform.h>
#include <stdio.h>
#include <string.h>

//#include "constants.h"
#include "utils.xc"
#include "utils/utils.h"

int ceil_div(int a, int b) {
    return (a/b) + ((a%b)?1:0);
}

// Define interface
interface worker_farmer {
    [[guarded]] [[clears_notification]] uint * movable get_ref();
    [[notification]] slave void tock();
    [[guarded]] void tick(uint* movable strip_ref, uint start_index, uint stop_index, uint width);
};

void farmer(int id, client interface worker_farmer wf_i[workers], static const uint workers) {
    printf("[%i] Farmer init\n", id);
    // TODO read in from image
    const int width = 64;
    const int height = 8;

    if (height % workers) {
        printf("Error: incompatible height to workers ratio\n\n");
        return;
    }
    int working_strip_height = height / workers; // TODO put in variable length strips?
    //int number_of_cells = working_strip_height * width;
    int ints_in_row = ceil_div(width, INT_SIZE);
    int ints_in_strip = (working_strip_height+2)*ints_in_row;
    //TODO add availabile_workers when different

    int top_overlap_row = 0;
    int first_working_row = ints_in_row;
    int last_working_row = ints_in_row * working_strip_height;
    int bottom_overlap_row = ints_in_row * (working_strip_height + 1);

    #define MAX_INTS_IN_STRIP  10 // TODO Optimise for memory

    uint * movable worker_strips[workers];
    //TODO: needs to malloc somehow and have array of movable pointers.
        //if malloced seperately, will the memory be in loads of ifferent physical locations?

    for (int worker_id=0; worker_id<workers; worker_id++) {
        worker_strips[worker_id] = malloc(MAX_INTS_IN_STRIP * INT_SIZE);
    }

    //NOTE arrays used for testing, will be image input later
    for (int worker_id=0; worker_id<workers; worker_id++) {
        for (int j=0; j<ints_in_strip; j++) {
            worker_strips[worker_id][j] = 0;
            if (worker_id == 1) worker_strips[worker_id][j] = 0x55555555;
            if (worker_id == 3) worker_strips[worker_id][j] = 0xaaaaaaaa;
        }
        //print_bits_array(worker_strips[worker_id], MAX_INTS_IN_STRIP);
    }
    printf("-------------\n");


    int pause = 0; // TODO update with button press
    while (!pause) {
        // TODO: calculate strip stats

        for (int worker_id=0; worker_id < workers; worker_id++) {
            int previous_worker_id = (worker_id-1) % workers;
            int next_worker_id = (worker_id+1) % workers;

            memcpy(&(worker_strips[worker_id][top_overlap_row]), &(worker_strips[previous_worker_id][last_working_row]), ints_in_row * sizeof(int));

            memcpy(&(worker_strips[worker_id][bottom_overlap_row]), &(worker_strips[next_worker_id][first_working_row]), ints_in_row * sizeof(int));

            uint * movable strip_ref = &worker_strips[worker_id][0];
            wf_i[worker_id].tick(move(strip_ref), first_working_row, last_working_row + ints_in_row, width);

        }

        int workers_done = workers;
        while (!workers_done) { // TODO: possible deadlock?
            select {
                case wf_i[int worker_id].tock():
                    uint *movable ref = wf_i[worker_id].get_ref();

                    printf("pointer: %i\n", ref);
                    print_bits_array(ref, MAX_INTS_IN_STRIP);
                    return;

                    workers_done--;
                    break;
            }
        }
        break;
    }
}

void worker(int id, server interface worker_farmer wf_i) {
    printf("[%i] Worker init\n", id);
    uint *movable ref;
    //Work on each tick
    while (1) {
        select {
            case wf_i.tick(uint *movable strip_ref, uint start_index, uint stop_index, uint width):
                // TODO: work
                ref = move(strip_ref);
                //uint * movable strip = move(strip_ref);
                printf("Compute between index: %i and %i\n", start_index, stop_index);
                //printf("%i%i%i\n", get_bit(strip, 0), get_bit(strip, 1), get_bit(strip, 2));
                printf("[%i] tick done\n", id);
                wf_i.tock();
                break;
            case wf_i.get_ref() -> uint *movable r:
                r = move(ref);
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