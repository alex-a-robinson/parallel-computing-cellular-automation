#include <platform.h>
#include <stdio.h>

// Define interface
interface worker_farmer {
    [[guarded]] [[clears_notification]] void init_strip(int start_index, int number_of_cells, int width, int height);
    [[notification]] slave void tock();
    [[guarded]] void tick(int strip_ref[], int start_index, int number_of_cells, int width, int height);
};

void farmer(int id, client interface worker_farmer wf_i[available_workers], static const uint available_workers) {
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
                wf_i[worker_id].tick(worker_strips[worker_id], start_index, number_of_cells, width, height);
            }
        }

        int workers_done = available_workers;
        do {
            select {
                case wf_i[int worker_id].tock():
                    workers_done--; // This worker is done! :)
                    break;
            }
        } while (!workers_done);
    } while (1);

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
