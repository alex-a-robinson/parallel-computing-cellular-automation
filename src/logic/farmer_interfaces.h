#ifndef FARMER_INTERFACES_H_
#define FARMER_INTERFACES_H_

interface worker_farmer {
    [[notification]] slave void tock();
    [[clears_notification]] void tick(unsigned int strip_ref[], uint first_working_row, uint last_working_row, uint widths, uint ints_in_row);
};

// AHAS
interface farmer_button_control {
    void start_read();
    void start_write();
};

interface read_image_farmer { // GREEN LED
    [[notification]] slave void start_read();
    void dimensions(unsigned int width, unsigned int height);
    void data(unsigned int num);
    [[clears_notification]] void read_done();
}

interface farmer_write_image { // BLUE LED
    [[notification]] slave void ready_for_data();
    void header(int width, int height);
    void data(unsigned int num);
    [[clears_notification]] void end_of_data();
}

interface farmer_orientation_control { // RED LED
    void pause();
    void play();
}

#endif
