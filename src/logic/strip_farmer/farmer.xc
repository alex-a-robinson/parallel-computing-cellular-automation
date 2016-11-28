#include <platform.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "constants.h"
#include "utils/debug.h"
#include "utils/utils.h"

#include "logic/farmer_interfaces.h"
#include "logic/strip_farmer/farmer.h"
#include "logic/strip_farmer/worker.h"
#include "logic/strip_farmer/worker_farmer_interface.h"


#include "utils.xc" // DEBUGGING

void farmer(int id, client interface worker_farmer_if workers_farmer[workers], static const unsigned int workers,
            server interface farmer_button_if farmer_buttons, client interface output_gpio_if led,
            server interface farmer_orientation_if farmer_orientation, server interface reader_farmer_if reader_farmer,
            client interface farmer_writer_if farmer_writer) {
    LOG(IFO, "[%i] Farmer init\n", id);


    int width, height, ints_in_row, working_strip_height;
    int top_overlap_row, first_working_row, last_working_row, bottom_overlap_row;
    unsigned int worker_strips[workers][MAX_INTS_IN_STRIP] = {{0}};
    int live_cells[workers] = {0};


    timer farmer_timer;
    unsigned int time_since_read;
    unsigned long tick_start_time, tick_stop_time;

    int play = 0;
    int tick = 0;
    int read_done = 0;
    while (1) {

        select {
        // Start Read/Write from farmer_buttons
        case farmer_buttons.start_read():
            LOG(IFO, "farmer_buttons.start_read()\n");
            read_done = 0;
            reader_farmer.start_read();
            // Read in entire image
            while (!read_done) {
                select {
                case reader_farmer.dimensions(unsigned int _width, unsigned int _height):
                    LOG(DBG, "reader_farmer.dimensions(%i, %i)\n", _width, _height);
                    width = _width;
                    height = _height;

                    if (height % workers) {
                        LOG(ERR, "Error: incompatible height to workers ratio\n");
                        return;
                    }
                    working_strip_height = height / workers; // TODO put in variable length strips?
                    ints_in_row = ceil_div(width, INT_SIZE);
                    top_overlap_row = 0;
                    first_working_row = ints_in_row;
                    last_working_row = ints_in_row * working_strip_height;
                    bottom_overlap_row = ints_in_row * (working_strip_height + 1);
                    // TODO add availabile_workers when different
                    break;

                case reader_farmer.data(unsigned int data, int row_index, int int_index):
                    LOG(DBG, "reader_farmer.data(%u, %i, %i)\n", data, row_index, int_index);
                    int strip_index = row_index / working_strip_height;
                    int row_in_strip = (row_index % working_strip_height) + 1;
                    worker_strips[strip_index][row_in_strip*ints_in_row + int_index] = data;
                    break;
                case reader_farmer.read_done():
                    LOG(IFO, "reader_farmer.read_done()\n");
                    read_done = 1;
                    tick = 0;
                    play = 1;
                    farmer_timer :> tick_start_time;
                    time_since_read = 0;
                    break;
                }
            }
            break; // start_read

        case read_done => farmer_buttons.start_write():
            LOG(IFO, "farmer_buttons.start_write()\n");
            farmer_writer.header(width, height);

            // For each worker; for each int in working strip; when ready send data
            for (int worker_id = 0; worker_id < workers; worker_id++) {
                for (int int_index = first_working_row; int_index < bottom_overlap_row; int_index++) {
                    select {
                    case farmer_writer.ready_for_data():
                        LOG(DBG, "farmer_writer.ready_for_data()\n");
                        unsigned int size = ((width % INT_SIZE) && (int_index % ints_in_row == ints_in_row - 1))
                                                ? width % INT_SIZE
                                                : INT_SIZE;
                        farmer_writer.data(worker_strips[worker_id][int_index], size);
                        break;
                    }
                }
            }
            farmer_writer.end_of_data();
            break; // start_write

        case read_done => farmer_orientation.pause():
            LOG(IFO, "farmer_orientation.pause()\n");
            play = 0;
            int total_live_cells = 0;
            for (int worker_id = 0; worker_id < workers; worker_id++) total_live_cells += live_cells[worker_id]; // TODO
            int time_per_tick = time_since_read/tick;
            printf("tick: %d, live: %d, time since read: %d.%.02d, time/tick: %d.%.02d\n",
                tick, total_live_cells, time_since_read/1000, time_since_read%1000, time_per_tick/1000, time_per_tick%1000);
            break;
        case read_done => farmer_orientation.play():
            LOG(IFO, "farmer_orientation.play()\n");
            play = 1;
            break;

        default:
            break;// for if no buttons or orientation changed since last check
        }



        if (read_done && play) {
            // system("clear"); DEBUG
            if (DEBUG_LEVEL==DBG) print_strips_as_grid(worker_strips, working_strip_height, workers, ints_in_row);

            // update neighboring overlaps
            for (int worker_id = 0; worker_id < workers; worker_id++) {
                int previous_worker_id = (worker_id - 1) % workers;
                int next_worker_id = (worker_id + 1) % workers;
                memcpy(&(worker_strips[worker_id][top_overlap_row]),
                       &(worker_strips[previous_worker_id][last_working_row]), ints_in_row * sizeof(int));
                memcpy(&(worker_strips[worker_id][bottom_overlap_row]),
                       &(worker_strips[next_worker_id][first_working_row]), ints_in_row * sizeof(int));
            }

            for (int worker_id = 0; worker_id < workers; worker_id++) {
                workers_farmer[worker_id].tick(worker_strips[worker_id], first_working_row, last_working_row, width,
                                               ints_in_row, &(live_cells[worker_id]));
            }

            int workers_done = workers;

            while (!workers_done) { // TODO: possible deadlock?
                select {
                case workers_farmer[int worker_id].tock():
                    LOG(DBG, "workers_farmer[%i].tock()\n", worker_id);
                    workers_done--;
                    break;
                }
            }

            tick++;
            if (tick%100 == 0) LOG(IFO, ".");
            led.output(tick % 2); // Blink LED, might not work

            farmer_timer :> tick_stop_time;
            time_since_read += (tick_stop_time - tick_start_time)/100000; // milliseconds
            farmer_timer :> tick_start_time;
        }
    }
}
