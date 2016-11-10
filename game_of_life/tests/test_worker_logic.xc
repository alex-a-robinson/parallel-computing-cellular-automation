#include <grids.c>
#include <../src/worker_logic.xc>



//typedef unsigned int uint;

void test_calc_cell();
void test_calc_line();
void test_get_bit();
void test_set_bit();

#define ASSERT(str, expr)  \
    if (!expr) \
        printf("  %s failed at line %i\n", str, __LINE__)


int comp_array(uint a[], uint b[], uint n) {
    for (int i = 0 ; i < n ; i++) {
        //TODO: add 2d functionality
        if (a[i] != b[i]) {
            return 0;
        }
    }
    return 1;
}

void print_array(uint array[], uint n) {
    for (uint i = 0 ; i < n ; i++) {
        //TODO add 2d fucnitonality
        printf("%i", array[i]);
    }
    printf("/n");
}

void print_bits(uint num) {
    for (uint i=0 ; i<INT_SIZE; i++){
        printf("%i", (num & (1<<INT_SIZE-i-1)) ? 1 : 0);
    }
    printf("\n");
}

uint array_to_bitfield(uint array[],uint n) {
    uint bitfield = 0;
    for (uint i=0 ; i < n ; i++) {
        if (array[i]) {
            bitfield |= (1<<i);
        }
    }
    return bitfield;
}

int main(void) {
    test_get_bit();
    test_set_bit();
    //test_calc_cell();
    return 0;
}

void test_get_bit(){
    printf("\ntest_get_bit:\n");
    uint array_0_0[2] = {0,0};
    ASSERT("get_bit(array_0_0,0) == 0)", get_bit(array_0_0,0) == 0);
    ASSERT("get_bit(array_0_0,15) == 0)", get_bit(array_0_0,15) == 0);
    ASSERT("get_bit(array_0_0,50) == 0)", get_bit(array_0_0,50) == 0);
    ASSERT("get_bit(array_0_0,63) == 0)", get_bit(array_0_0,63) == 0);


    uint array_1_1[2] = {1,1};
    ASSERT("get_bit(array_1_1,0) == 1", get_bit(array_1_1,0) == 1);
    ASSERT("get_bit(array_1_1,1) == 0", get_bit(array_1_1,1) == 0);
    ASSERT("get_bit(array_1_1,31) == 0", get_bit(array_1_1,31) == 0);
    ASSERT("get_bit(array_1_1,32) == 1", get_bit(array_1_1,32) == 1);
    ASSERT("get_bit(array_1_1,33) == 0", get_bit(array_1_1,33) == 0);

    printf("done.\n\n");
}


void test_set_bit(){
    printf("\ntest_set_bit:\n");
    uint array_0_0[2] = {0,0};
    uint array_1_0[2] = {1,0};
    uint array_4_0[2] = {4,0};
    uint array_0_1[2] = {0,1};
    uint array_1_1[2] = {1,1};

    uint test1[2] = {0,0};
    set_bit(test1,0,0);
    ASSERT("1 set_bit(array_0_0,0,0) -> array_0_0", comp_array(test1, array_0_0,2));

    uint test2[2] = {0,0};
    set_bit(test2,0,1);
    ASSERT("2 set_bit(array_0_0,0,1) -> array_1_0", comp_array(test2, array_1_0,2));

    uint test3[2] = {0,0};
    set_bit(test3,2,1);
    ASSERT("3 set_bit(array_0_0,2,1) -> array_4_0", comp_array(test3, array_4_0,2));

    uint test4[2] = {0,0};
    set_bit(test4,32,1);
    ASSERT("4 set_bit(array_0_0,32,1) -> array_0_1", comp_array(test4, array_0_1,2));

    uint test5[2] = {0,0};
    set_bit(test5,0,1);
    set_bit(test5,32,1);
    ASSERT("5 set_bit(test5,0,1); set_bit(test5,32,1); -> array_1_1", comp_array(test5, array_1_1,2));



    printf("done.\n\n");
}


void test_calc_cell() {
    printf("\ntest_calc_cell:\n");
    ASSERT("calc_cell(cell_group_zeros", calc_cell(array_to_bitfield(cell_group_zeros,9)) == 0);
    ASSERT("calc_cell(cell_group_ones", calc_cell(array_to_bitfield(cell_group_ones,9)) == 0);
    ASSERT("calc_cell(cell_group_no_change_0", calc_cell(array_to_bitfield(cell_group_no_change_0,9)) == 0);
    ASSERT("calc_cell(cell_group_no_change_1", calc_cell(array_to_bitfield(cell_group_no_change_1,9)) == 1);
    ASSERT("calc_cell(cell_group_born", calc_cell(array_to_bitfield(cell_group_born,9)) == 1);
    ASSERT("calc_cell(cell_group_overpopulated", calc_cell(array_to_bitfield(cell_group_overpopulated,9)) == 0);

    printf("done.\n\n");
}

void test_calc_line() {
    /*
    uint lg[8];
    calc_line(line_group_8_3_zeros,lg,8);
    ASSERT("calc_line(line_group_8_3_zeros", memcmp(lg, line_8_1_zeros, 8));

    calc_line(line_group_8_3_ones,lg,8);
    ASSERT("calc_line(line_group_8_3_ones", memcmp(lg, line_8_1_zeros, 8));

    calc_line(line_group_8_3_checker_board,lg,8);
    ASSERT("calc_line(line_group_8_3_checker_boa", memcmp(lg, line_8_1_zeros, 8));

    calc_line(line_group_8_3_checker_board_inverse,lg,8);
    ASSERT("calc_lineline_group_8_3_checker_board_inverse", memcmp(lg, line_8_1_zeros, 8));

    calc_line(line_group_8_3_strips,lg, 8);
    ASSERT("calc_line(line_group_8_3_strips,lg, ", memcmp(lg, line_8_1_alternating, 8));

    calc_line(line_group_8_3_strips_inverse,lg, 8);
    ASSERT("calc_line(line_group_8_3_strips_inverse", memcmp(lg, line_8_1_alternating_inverse, 8));

    calc_line(line_group_8_3_zeros_centre_ones,lg,8);
    ASSERT("calc_line(line_group_8_3_zeros_centre_ones", memcmp(lg, line_8_1_ones, 8));

    calc_line(line_group_8_3_ones_centre_zeros,lg,8);
    ASSERT("calc_line(line_group_8_3_ones_centre_zeros", memcmp(lg, line_8_1_zeros, 8));
*/
}

/*

    //TestWorker():
    ASSERT(worker(line_group_8_3_zeros, 1, 8) == line_8_1_zeros);
    ASSERT(worker(line_group_8_3_ones, 1, 8) == line_8_1_zeros);
    ASSERT(worker(line_group_4_3_zeros, 1, 4) == line_4_1_zeros);
    ASSERT(worker(strips1_8_8_zeros[0], 8, 8) == grid_8_8_zeros);
    ASSERT(worker(strips2_8_8_zeros[0], 4, 8) == [0] * 32);
    ASSERT(worker(strips3_8_8_zeros[0], 3, 8) == [0] * 24);
    ASSERT(worker(strips3_8_8_zeros[2], 2, 8) == [0] * 16);
    ASSERT(worker(strips4_8_8_zeros[0], 2, 8) == [0] * 16);

    //TestFarmer():
    ASSERT(farmer(grid_8_8_ones, 8) == grid_8_8_zeros);
    ASSERT(farmer(grid_8_8_zeros, 8) == grid_8_8_zeros);
    ASSERT(farmer(grid_8_8_alternating, 8) == grid_8_8_zeros);
    ASSERT(farmer(grid_8_8_alternating_inverse, 8) == grid_8_8_zeros);
    ASSERT(farmer(grid_8_8_strips, 8) == grid_8_8_strips);
    ASSERT(farmer(grid_8_8_strips_inverse, 8) == grid_8_8_strips_inverse);
    ASSERT(farmer(grid_8_8_glider_1, 8) == grid_8_8_glider_2);
    ASSERT(farmer(grid_8_8_glider_2, 8) == grid_8_8_glider_3);
    ASSERT(farmer(grid_8_8_glider_3, 8) == grid_8_8_glider_4);
    ASSERT(farmer(farmer(grid_8_8_glider_1, 8), 8) == grid_8_8_glider_3);
    ASSERT(farmer(farmer(grid_8_8_glider_2, 8), 8) == grid_8_8_glider_4);
    ASSERT(farmer(farmer(farmer(grid_8_8_glider_1, 8), 8), 8) == grid_8_8_glider_4);
    ASSERT(farmer(grid_5_16_glider_1, 5, 1) == grid_5_16_glider_2);
    ASSERT(farmer(grid_5_16_glider_1, 5, 4) == grid_5_16_glider_2);
    ASSERT(farmer(grid_5_16_glider_1, 5, 5) == grid_5_16_glider_2);
    ASSERT(farmer(grid_5_16_glider_1, 5, 7) == grid_5_16_glider_2);
    ASSERT(farmer(grid_5_16_glider_1, 5, 8) == grid_5_16_glider_2);
    ASSERT(farmer(grid_5_16_glider_1, 5, 10) == grid_5_16_glider_2);
    ASSERT(farmer(grid_5_16_glider_1, 5, 16) == grid_5_16_glider_2);
    ASSERT(farmer(grid_16_16_glider_1, 16) == grid_16_16_glider_2);
    ASSERT(farmer(grid_8_8_glider_1, 8, num_of_workers=1) == grid_8_8_glider_2);
    ASSERT(farmer(grid_8_8_glider_1, 8, num_of_workers=2) == grid_8_8_glider_2);
    ASSERT(farmer(grid_8_8_glider_1, 8, num_of_workers=4) == grid_8_8_glider_2);
    ASSERT(farmer(grid_8_8_glider_1, 8, num_of_workers=8) == grid_8_8_glider_2);
    ASSERT(farmer(grid_8_8_glider_1, 8, num_of_workers=3) == grid_8_8_glider_2);
    ASSERT(farmer(grid_8_8_glider_1, 8, num_of_workers=5) == grid_8_8_glider_2);

    for (uint i=0 ; i<10 ; i++) {//can use bigger numbers than ten but slows dramatically:
        ASSERT(farmer(diagonals[i]) == diagonal[i]);
    }
    //  takes ages
    //  ASSERT(farmer(grid_512_512_diagonal, 512, 1) == grid_512_512_diagonal);
    //  ASSERT(farmer(grid_512_512_diagonal, 512, 14) == grid_512_512_diagonal);
    //  ASSERT(farmer(grid_512_512_diagonal, 512, 10_0) == grid_512_512_diagonal);
    //  ASSERT(farmer(grid_512_512_diagonal, 512, 40_0) == grid_512_512_diagonal);


    //TestSplitter():
    ASSERT(split_into_strips(grid_8_8_zeros, 8, 8, 1) == strips1_8_8_zeros);
    ASSERT(split_into_strips(grid_8_8_zeros, 8, 8, 2) == strips2_8_8_zeros);
    ASSERT(split_into_strips(grid_8_8_zeros, 8, 8, 3) == strips3_8_8_zeros);
    ASSERT(split_into_strips(grid_8_8_zeros, 8, 8, 4) == strips4_8_8_zeros);
    ASSERT(split_into_strips(grid_8_8_zeros, 8, 8, 5) == strips4_8_8_zeros);
    ASSERT(split_into_strips(grid_8_8_half_and_half, 8, 8, 2) == strips2_8_8_half_and_half);
    ASSERT(split_into_strips(grid_8_8_range, 8, 8, 1) == strips1_8_8_range);
    ASSERT(split_into_strips(grid_8_8_range, 8, 8, 2) == strips2_8_8_range);
    ASSERT(split_into_strips(grid_8_8_range, 8, 8, 3) == strips3_8_8_range);
    ASSERT(split_into_strips(grid_8_8_range, 8, 8, 4) == strips4_8_8_range);
    */
