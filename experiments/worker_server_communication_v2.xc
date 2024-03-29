#include <platform.h>
#include <stdio.h>

// Define interface
interface worker_farmer_if {
    [[guarded]] [[clears_notification]] void init_strip(int start_index, int number_of_cells, int width, int height);
    [[notification]] slave void tock();
    [[guarded]] void tick(int strip_ref[], int start_index, int number_of_cells, int width, int height);
};

void farmer(int id, client interface worker_farmer_if workers_farmer[available_workers], static const unsigned int available_workers) {
    printf("[%i] Farmer init\n", id);
    const int width = 32;
    const int height = 4;
    const int strip_height = (width * height) / available_workers; // TODO change strip_size to strip_height
    const int number_of_cells = strip_height * width;

    // Simulates a max 64x4 grid
    int worker_strips[available_workers][2];


    int pause = 0; // TODO update with button press

    do {
        // TODO: Recalculate strips - neightbour
        // TODO: calculate strip stats

        if (!pause) {
            for (int worker_id=0; worker_id < available_workers; worker_id++) {
                workers_farmer[worker_id].tick(worker_strips[worker_id], start_index, number_of_cells, width, height);
            }
        }

        int workers_done = available_workers;
        do {
            select {
                case workers_farmer[int worker_id].tock():
                    workers_done--; // This worker is done! :)
                    break;
            }
        } while (!workers_done);
    } while (1);

}

void worker(int id, server interface worker_farmer_if workers_farmer) {
    printf("[%i] Worker init\n", id);

    // Work on each tick
    while (1) {
        select {
            case workers_farmer.tick(int ref[], int start_index, int number_of_cells, int width, int height):
                // TODO: work
                printf("[%i] tick done\n", id);
                workers_farmer.tock();
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
