#include <platform.h>
#include <stdio.h>

// Define interface
interface farmer_worker_command {
    void f(int x);
    [[clears_notification]] int get_data();
    [[notification]] slave void data_ready(void);
};

void farmer(int id, server interface farmer_worker_command fwc[n], unsigned n) {
    //printf("farmer %i\n", id);

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
    }
}

void worker(int id, client interface farmer_worker_command fwc) {
    printf("[%i] Worker init\n", id);
    fwc.f(id);
    int data;
    select {
        case fwc.data_ready():
            data = fwc.get_data();
            break;
    }

    printf("[%i] Got data: %i\n", id, data);
}

int main(void) {
    interface farmer_worker_command fwc[2];

    par {
        farmer(0, fwc, 2);
        worker(1, fwc[0]);
        worker(2, fwc[1]);
    }
    return 0;
}
