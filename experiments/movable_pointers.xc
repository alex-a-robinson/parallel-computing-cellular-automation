#include <platform.h>
#include <stdio.h>
#include <string.h>


#include "constants.h"
#include "utils.xc"
#include "utils/utils.h"

int ceil_div(int a, int b) {
    return (a/b) + ((a%b)?1:0);
}

// Define interface
interface worker_farmer_if {
    [[guarded]] [[clears_notification]] unsigned int * movable get_ref();
    [[notification]] slave void tock();
    [[guarded]] void tick(unsigned int* movable strip_ref, unsigned int start_index, unsigned int stop_index, unsigned int width);
};

void farmer(int id, client interface worker_farmer_if workers_farmer[workers], static const unsigned int workers) {
    printf("[%i] Farmer init\n", id);
    // TODO read in from image
    const int width = 64;
    const int height = 8;
    if (height % workers) {
        printf("Error: incompatible height to workers ratio\n\n");
        return;
    }

    int working_strip_height = height / workers; // TODO put in variable length strips?
    int ints_in_row = ceil_div(width, INT_SIZE);
    int ints_in_strip = (working_strip_height+2)*ints_in_row;
    //TODO add availabile_workers when different

    int top_overlap_row = 0;
    int first_working_row = ints_in_row;
    int last_working_row = ints_in_row * working_strip_height;
    int bottom_overlap_row = ints_in_row * (working_strip_height + 1);

    #define MAX_INTS_IN_STRIP  10 // TODO Optimise for memory

    unsigned int * movable worker_strips[workers];

//TODO: needs to malloc somehow and have array of movable pointers.
        //if memory allocated seperately, will the memory be in loads of ifferent physical locations?
        // will that havae any actual difference on speed?

    //unsigned int * movable temp_ref; //keep scope?
    for (int worker_id=0; worker_id<workers; worker_id++) {
        static unsigned int current_strip[MAX_INTS_IN_STRIP]; //TODO: check for memory leak here
        for (int j=0; j<ints_in_strip; j++) {
            //TODO: replace these with incoming image channel
            current_strip[j] = 0;
            if (worker_id == 1) current_strip[j] = 0x55555555;
            if (worker_id == 3) current_strip[j] = 0xaaaaaaaa;
        static unsigned int * movable temp_ref = current_strip; //TODO: dsicuss this 0
        worker_strips[worker_id] = move(temp_ref);
        }

        printf("-\n");
        for (int i = 0; i < MAX_INTS_IN_STRIP; i++) {
            //TODO add 2d fucnitonality
            for (int j=0 ; j<INT_SIZE; j++){
                printf("%i", (worker_strips[worker_id][i] & (1<<(INT_SIZE-j-1))) ? 1 : 0);
            }
            printf("\n");
        }
        printf("\n");

    }
    printf("-------------\n");


    int pause = 0; // TODO update with button press
    while (!pause) {
        // TODO: calculate strip stats

        for (int worker_id=0; worker_id < workers; worker_id++) {
            int previous_worker_id = (worker_id-1) % workers;
            int next_worker_id = (worker_id+1) % workers;

            printf("%i, %i, %i, %i \n", worker_id, previous_worker_id, last_working_row, &(worker_strips[previous_worker_id][last_working_row]));

            memcpy(&(worker_strips[worker_id][top_overlap_row]), &(worker_strips[previous_worker_id][last_working_row]), ints_in_row * sizeof(int));

            memcpy(&(worker_strips[worker_id][bottom_overlap_row]), &(worker_strips[next_worker_id][first_working_row]), ints_in_row * sizeof(int));

            unsigned int * movable strip_ref = &worker_strips[worker_id][0];
            workers_farmer[worker_id].tick(move(strip_ref), first_working_row, last_working_row + ints_in_row, width);

        }

        int workers_done = workers;
        while (!workers_done) { // TODO: possible deadlock?
            select {
                case workers_farmer[int worker_id].tock():
                    unsigned int *movable ref = workers_farmer[worker_id].get_ref();

                    printf("pointer: %i\n", ref);
                    //print_bits_array(ref, MAX_INTS_IN_STRIP);
                    return;

                    workers_done--;
                    break;
            }
        }
        break;
    }
}

void worker(int id, server interface worker_farmer_if workers_farmer) {
    printf("[%i] Worker init\n", id);
    unsigned int *movable ref;
    //Work on each tick
    while (1) {
        select {
            case workers_farmer.tick(unsigned int *movable strip_ref, unsigned int start_index, unsigned int stop_index, unsigned int width):
                // TODO: work
                ref = move(strip_ref);
                //unsigned int * movable strip = move(strip_ref);
                printf("Compute between index: %i and %i\n", start_index, stop_index);
                //printf("%i%i%i\n", get_bit(strip, 0), get_bit(strip, 1), get_bit(strip, 2));
                printf("[%i] tick done\n", id);
                workers_farmer.tock();
                break;
            case workers_farmer.get_ref() -> unsigned int *movable r:
                r = move(ref);
                break;
        }
    }
}

int main(void) {
    interface worker_farmer_if workers_farmer[4];

    par {
        on tile[0] : farmer(9, workers_farmer, 4);
        on tile[0] : worker(0, workers_farmer[0]);
        on tile[0] : worker(1, workers_farmer[1]);
        on tile[0] : worker(2, workers_farmer[2]);
        on tile[0] : worker(3, workers_farmer[3]);
    }
    return 0;
}
