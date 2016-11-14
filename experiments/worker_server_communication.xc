#include <platform.h>
#include <stdio.h>

// Define interface
/*interface worker_farmer {
    void strip(int strip[], int updated_strip[], int start_index, int number_of_cells, int width, int height);
    [[clears_notification]] int get_worker_strip();
    [[notification]] slave void worker_done();
};*/

// Define interface
interface i {
    [[clears_notification]] void f(int ref[]);
    [[notification]] slave void done();
};

void farmer(int id, client interface i fwc) {//[n], unsigned n) {
    //printf("farmer %i\n", id);

    // Simulates a max 64x4 grid
    //int worker_strips[4][2];

    int array_1[] = {1,2,3};

    fwc.f(array_1);

    while (1) {
        select {
            case fwc.done():
                printf("%i, %i, %i\n", array_1[0], array_1[1], array_1[2]);
                array_1[2] = 5;
                printf("%i, %i, %i\n", array_1[0], array_1[1], array_1[2]);
                fwc.f(array_1);
                break;
        }
    }
/*
    while(1) {
        select {
            case fwc[int i].get_data() -> int data:
                data = 100*(i+1);
                break;
//            case fwc[1].get_data() -> int data:
//                data = b;
//                break;
            case fwc[int i].f(int x):
                printf("[%i] Got %i from %i\n", id, x, i+1);
                fwc[i].data_ready();
                break;
        }
    }*/
}

void worker(int id, server interface i fwc) {
    printf("[%i] Worker init\n", id);
    while (1) {
        select {
            case fwc.f(int ref[]):
                ref[2] = 4;
                fwc.done();
                break;
        }
    }
}

int main(void) {
    interface i fwc;

    par {
        farmer(0, fwc);
        worker(1, fwc);//[0]);
        //worker(2, fwc[1]);
    }
    return 0;
}
