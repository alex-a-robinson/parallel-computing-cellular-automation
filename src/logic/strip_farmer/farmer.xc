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

/* Farmer process funciton
 * - Watches controls (buttons + orientation)
 * - Handles reading/writing of grid
 * - Handles splitting grid into strips
 * - Handles assigning workers to strips
 */
void farmer(int id, client interface worker_farmer_if workers_farmer[workers], static const unsigned int workers,
            server interface farmer_button_if farmer_buttons, client interface output_gpio_if led,
            server interface farmer_orientation_if farmer_orientation, server interface reader_farmer_if reader_farmer,
            client interface farmer_writer_if farmer_writer) {
    LOG(IFO, "[%i] Farmer init\n", id);

    // -- Initialise varibles and timers
    // Grid
    int width, height, ints_in_row, working_strip_height;
    int top_overlap_row, first_working_row, last_working_row, bottom_overlap_row;
    unsigned int worker_strips[workers][MAX_INTS_IN_STRIP] = {{0}};

    // Stats
    int live_cells[workers] = {0};

    // Timers
    timer farmer_timer;
    unsigned int time_since_read, tick_start_time, tick_stop_time;
    timer reader_timer;
    unsigned int read_start_time, read_end_time;

    // Game state
    int play = 0;
    int tick = 0;
    int read_done = 0;

    /*
     * Main loop
     */
    while (1) {
        // Wait for a control, if nothing queued continue
        select {
            // When start read button pressed, start reading into strips
            case farmer_buttons.start_read():
                LOG(IFO, "farmer_buttons.start_read()\n");

                reader_timer :> read_start_time;
                read_done = 0;
                reader_farmer.start_read();

                // Wait for a response from reader interface while we're not done
                while (!read_done) {
                    select {
                        // Read the dimensions, update strip varibles
                        case reader_farmer.dimensions(unsigned int _width, unsigned int _height):
                            LOG(DBG, "reader_farmer.dimensions(%i, %i)\n", _width, _height);

                            // TODO Varible workers
                            if (_height % workers) {
                                LOG(ERR, "Error: incompatible height to workers ratio\n");
                                return;
                            }

                            // Update width, height and caluclate strip varibles
                            width = _width;
                            height = _height;

                            working_strip_height = height / workers; // TODO put in variable length strips?
                            ints_in_row = ceil_div(width, INT_SIZE);
                            top_overlap_row = 0;
                            first_working_row = ints_in_row;
                            last_working_row = ints_in_row * working_strip_height;
                            bottom_overlap_row = ints_in_row * (working_strip_height + 1);

                            break;

                        // Read data from the reader
                        case reader_farmer.data(unsigned int data, int row_index, int int_index):
                            if (row_index % 10 == 0 && int_index == 0) LOG(DBG, "reader_farmer.data(%u, %i, %i)\n", data, row_index, int_index);

                            // Calculate which strip and row to place the data into
                            int strip_index = row_index / working_strip_height;
                            int row_in_strip = (row_index % working_strip_height) + 1;
                            worker_strips[strip_index][row_in_strip*ints_in_row + int_index] = data;
                            break;

                        // Done read!
                        case reader_farmer.read_done():
                            LOG(IFO, "reader_farmer.read_done()\n");
                            read_done = 1;
                            break;
                    }
                }

                // Once read done, reset game varibles and timers
                tick = 0;
                play = 1;
                time_since_read = 0;
                farmer_timer :> tick_start_time;
                reader_timer :> read_end_time;

                break;

            // When start write button pressed
            case read_done => farmer_buttons.start_write():
                LOG(IFO, "farmer_buttons.start_write()\n");

                farmer_writer.header(width, height);

                // For each worker; for each int in working strip; when ready send data
                for (int worker_id = 0; worker_id < workers; worker_id++) {
                    for (int int_index = first_working_row; int_index < bottom_overlap_row; int_index++) {
                        select {
                            case farmer_writer.ready_for_data():
                                LOG(DBG, "farmer_writer.ready_for_data()\n");

                                // Calcuate if int is full size or padded
                                unsigned int size = ((width % INT_SIZE) && (int_index % ints_in_row == ints_in_row - 1))
                                                        ? width % INT_SIZE
                                                        : INT_SIZE;
                                farmer_writer.data(worker_strips[worker_id][int_index], size);
                                break;
                        }
                    }
                }

                farmer_writer.end_of_data();
                break;

            // When paused
            case read_done => farmer_orientation.pause():
                LOG(IFO, "farmer_orientation.pause()\n");
                play = 0;

                int time_per_tick = time_since_read / tick;

                // Calculate num live cells by summing live_cells
                int total_live_cells = 0;
                for (int worker_id = 0; worker_id < workers; worker_id++) total_live_cells += live_cells[worker_id];

                printf("tick: %d, live: %d, time since read: %d.%.02d, time/tick: %d.%.02d\n",
                    tick, total_live_cells, time_since_read/1000, time_since_read%1000, time_per_tick/1000, time_per_tick%1000);

                break;

            // When play
            case read_done => farmer_orientation.play():
                LOG(IFO, "farmer_orientation.play()\n");
                play = 1;
                break;

            // for if no buttons or orientation changed since last check
            default:
                break;
        }

        // contiue if paused
        if (!play) {
            continue;
        }

        if (DEBUG_LEVEL==DBG) print_strips_as_grid(worker_strips, working_strip_height, workers, ints_in_row);

        // Update neighbour overlaps, previous workers bottom row -> bottom row & next workers top row -> top row
        for (int worker_id = 0; worker_id < workers; worker_id++) {
            // TODO varible length strips - if last worker, change values of last working row
            int previous_worker_id = (worker_id - 1) % workers;
            int next_worker_id = (worker_id + 1) % workers;
            memcpy(&(worker_strips[worker_id][top_overlap_row]),
                   &(worker_strips[previous_worker_id][last_working_row]), ints_in_row * sizeof(int));
            memcpy(&(worker_strips[worker_id][bottom_overlap_row]),
                   &(worker_strips[next_worker_id][first_working_row]), ints_in_row * sizeof(int));
        }

        // Once overlaps are swapped tell workers to start
        for (int worker_id = 0; worker_id < workers; worker_id++) {
            workers_farmer[worker_id].tick(worker_strips[worker_id], first_working_row, last_working_row, width,
                                           ints_in_row, &(live_cells[worker_id]));
        }

        // Wait until every work is done
        int workers_done = workers;
        while (!workers_done) {
            select {
                case workers_farmer[int worker_id].tock():
                    LOG(DBG, "workers_farmer[%i].tock()\n", worker_id);
                    workers_done--;
                    break;
                }
        }

        // Update tick count and toggle LED
        tick++;
        led.output(tick % 2); // Blink LED, might not work

        // Update timers
        farmer_timer :> tick_stop_time;
        time_since_read += (tick_stop_time - tick_start_time) / 100000; // milliseconds
        farmer_timer :> tick_start_time;

        if (tick%100 == 0)LOG(IFO, ".");
    }
}
