#include <grids.c>
#include <string.h>
#include <../src/worker_logic.xc>


#define ASSERT(t, expr)  \
    if (!expr) \
        printf("%s failed at line %i\n", t, __LINE__)



int main(void) {
    // TestCalcCell():
    ASSERT("calc_cell(cell_group_zeros", calc_cell(cell_group_zeros) == 0);
    ASSERT("calc_cell(cell_group_ones", calc_cell(cell_group_ones) == 0);
    ASSERT("calc_cell(cell_group_no_change_0", calc_cell(cell_group_no_change_0) == 0);
    ASSERT("calc_cell(cell_group_no_change_1", calc_cell(cell_group_no_change_1) == 1);
    ASSERT("calc_cell(cell_group_born", calc_cell(cell_group_born) == 1);
    ASSERT("calc_cell(cell_group_overpopulat", calc_cell(cell_group_overpopulated) == 0);

    //TestCalcLine():
    int lg[8];
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

    for (int i=0 ; i<10 ; i++) {//can use bigger numbers than ten but slows dramatically:
        ASSERT(farmer(diagonals[i]) == diagonal[i]);
    }
    //  takes ages
    //  ASSERT(farmer(grid_512_512_diagonal, 512, 1) == grid_512_512_diagonal);
    //  ASSERT(farmer(grid_512_512_diagonal, 512, 14) == grid_512_512_diagonal);
    //  ASSERT(farmer(grid_512_512_diagonal, 512, 100) == grid_512_512_diagonal);
    //  ASSERT(farmer(grid_512_512_diagonal, 512, 400) == grid_512_512_diagonal);


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



    return 0;
}
