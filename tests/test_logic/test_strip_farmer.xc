#include <stdio.h>
#include "utils.h"
#include "tests.h"
#include "logic/strip_farmer.xc"

/*
void test_calc_cell() {
    printf("-- calc_cell --\n");

    uint strip_32_4_zeros[4] = {0, 0, 0, 0};
    uint strip_32_4_ones[4]  = {0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff};
    uint strip_32_4_columns[4] = {0xaaaaaaaa, 0xaaaaaaaa, 0xaaaaaaaa, 0xaaaaaaaa};
    uint strip_32_4_columns_inv[4] = {0x55555555, 0x55555555, 0x55555555, 0x55555555};

    //uint strip_32_4_diagonal[4] = {8, 4, 2, 1};
    //uint strip_32_4_diagonal_inv[4] = {1,2,4,8};
    //TODO diagonal test
    //uint strip_32_8_diagonal_inv[4] = {1,2,4,8,16,32,64,128};

    ASSERT("calc_cell(33, strip_32_4_zeros, 32) == 0)", calc_cell(33, strip_32_4_zeros, 32, 4) == 0);
    ASSERT("calc_cell(33, strip_32_4_ones, 32) == 0)", calc_cell(33, strip_32_4_ones, 32, 4) == 0);
    ASSERT("calc_cell(63, strip_32_4_ones, 32) == 0)", calc_cell(63, strip_32_4_ones, 32, 4) == 0);
    ASSERT("calc_cell(32, strip_32_4_columns, 32) == 1", calc_cell(32, strip_32_4_columns, 32, 4) == 1);
    ASSERT("alc_cell(33, strip_32_4_columns, 32) == 0", calc_cell(33, strip_32_4_columns, 32, 4) == 0);
    ASSERT("calc_cell(32, strip_32_4_columns_inv, 32) == 0", calc_cell(32, strip_32_4_columns_inv, 32, 4) == 0);
    ASSERT("alc_cell(33, strip_32_4_columns_inv, 32) == 1", calc_cell(33, strip_32_4_columns_inv, 32, 4) == 1);

    printf("\n");
}

void test_worker() {
    printf("-- worker --\n");

//worker(uint grid[], uint updated_strip[], uint start_index, uint number_of_cells, uint height, uint width) {
    uint grid_32_8_zeros[8] = {0, 0, 0, 0, 0, 0, 0, 0};
    //uint grid_32_8_ones[8]  = {0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff};
    //uint grid_32_8_columns[8] = {0xaaaaaaaa, 0xaaaaaaaa, 0xaaaaaaaa, 0xaaaaaaaa, 0xaaaaaaaa, 0xaaaaaaaa, 0xaaaaaaaa, 0xaaaaaaaa};
    //uint grid_32_8_columns_inv[8] = {0x55555555, 0x55555555, 0x55555555, 0x55555555, 0x55555555, 0x55555555, 0x55555555, 0x55555555};
    uint strip_32_4_zeros[4] = {0,0,0,0};
    uint updated_strip[4];
    //TODO add channels
    worker(grid_32_8_zeros, updated_strip, 0, 32*4, 32, 8);
    ASSERT("worker(grid_32_8_zeros)",compare_arrays(updated_strip, strip_32_4_zeros, 4));

    printf("\n");
}

void test_strip_farmer() {
    printf("== Testing logic/strip_farmer.xc ==\n");
    test_calc_cell();
    test_worker();
    printf("========\n\n");
}
*/
