from grids import *
from strip_farm import *
from utils import *


class TestCalcCell():
    '''Test calc_cell'''

    def test_empty_cell_group(self):
        assert calc_cell(cell_group_zeros) == dead

    def test_full_cell_group(self):
        assert calc_cell(cell_group_ones) == dead

    def test_no_change(self):
        assert calc_cell(cell_group_no_change_dead) == dead
        assert calc_cell(cell_group_no_change_alive) == alive

    def test_born(self):
        assert calc_cell(cell_group_born) == alive

    def test_overpopulated(self):
        assert calc_cell(cell_group_overpopulated) == dead


class TestCalcLine():
    '''Test calc_line'''

    def test_output_line_width(self):
        '''Test output line is same size as line_group width'''
        assert len(calc_line(line_group_8_3_zeros)) == 8
        assert len(calc_line(line_group_4_3_zeros)) == 4

    def test_zeros_under_over_population(self):
        assert calc_line(line_group_8_3_zeros) == line_8_1_zeros
        assert calc_line(line_group_8_3_ones) == line_8_1_zeros

    def test_checker_board(self):
        assert calc_line(line_group_8_3_checker_board) == line_8_1_zeros
        assert calc_line(line_group_8_3_checker_board_inverse) == line_8_1_zeros

    def test_strips(self):
        assert calc_line(line_group_8_3_strips) == line_8_1_alternating
        assert calc_line(line_group_8_3_strips_inverse) == line_8_1_alternating_inverse

    def test_centre_inverse(self):
        assert calc_line(line_group_8_3_zeros_centre_ones) == line_8_1_ones
        assert calc_line(line_group_8_3_ones_centre_zeros) == line_8_1_zeros


class TestWorker():
    '''Test worker'''

    def test_step_size_1(self):
        assert worker(line_group_8_3_zeros, 1, 8) == line_8_1_zeros
        assert worker(line_group_8_3_ones, 1, 8) == line_8_1_zeros
        assert worker(line_group_4_3_zeros, 1, 4) == line_4_1_zeros

    def test_zeros(self):
        assert worker(strips1_8_8_zeros[0], 8, 8) == grid_8_8_zeros
        assert worker(strips2_8_8_zeros[0], 4, 8) == [0] * 32
        assert worker(strips3_8_8_zeros[0], 3, 8) == [0] * 24
        assert worker(strips3_8_8_zeros[2], 2, 8) == [0] * 16
        assert worker(strips4_8_8_zeros[0], 2, 8) == [0] * 16


class TestFarmer():
    '''Test farmer'''

    def test_all_dead(self):
        assert farmer(grid_8_8_ones, 8) == grid_8_8_zeros
        assert farmer(grid_8_8_zeros, 8) == grid_8_8_zeros

    def test_alternating(self):
        assert farmer(grid_8_8_alternating, 8) == grid_8_8_zeros
        assert farmer(grid_8_8_alternating_inverse, 8) == grid_8_8_zeros

    def test_strips(self):
        assert farmer(grid_8_8_strips, 8) == grid_8_8_strips
        assert farmer(grid_8_8_strips_inverse, 8) == grid_8_8_strips_inverse

    def test_glider_8_8(self):
        assert farmer(grid_8_8_glider_1, 8) == grid_8_8_glider_2
        assert farmer(grid_8_8_glider_2, 8) == grid_8_8_glider_3
        assert farmer(grid_8_8_glider_3, 8) == grid_8_8_glider_4

    def test_double_glider_8_8(self):
        assert farmer(farmer(grid_8_8_glider_1, 8), 8) == grid_8_8_glider_3
        assert farmer(farmer(grid_8_8_glider_2, 8), 8) == grid_8_8_glider_4

    def test_triple_glider_8_8(self):
        assert farmer(farmer(farmer(grid_8_8_glider_1, 8), 8), 8) == grid_8_8_glider_4

    def test_glider_5_16(self):
        assert farmer(grid_5_16_glider_1, 5, 1) == grid_5_16_glider_2
        assert farmer(grid_5_16_glider_1, 5, 4) == grid_5_16_glider_2
        assert farmer(grid_5_16_glider_1, 5, 5) == grid_5_16_glider_2
        assert farmer(grid_5_16_glider_1, 5, 7) == grid_5_16_glider_2
        assert farmer(grid_5_16_glider_1, 5, 8) == grid_5_16_glider_2
        assert farmer(grid_5_16_glider_1, 5, 10) == grid_5_16_glider_2
        assert farmer(grid_5_16_glider_1, 5, 16) == grid_5_16_glider_2

    def test_glider_16_16(self):
        assert farmer(grid_16_16_glider_1, 16) == grid_16_16_glider_2

    def test_worker_num(self):
        assert farmer(grid_8_8_glider_1, 8, num_of_workers=1) == grid_8_8_glider_2
        assert farmer(grid_8_8_glider_1, 8, num_of_workers=2) == grid_8_8_glider_2
        assert farmer(grid_8_8_glider_1, 8, num_of_workers=4) == grid_8_8_glider_2
        assert farmer(grid_8_8_glider_1, 8, num_of_workers=8) == grid_8_8_glider_2
        assert farmer(grid_8_8_glider_1, 8, num_of_workers=3) == grid_8_8_glider_2
        assert farmer(grid_8_8_glider_1, 8, num_of_workers=5) == grid_8_8_glider_2

    def test_diagonals(self):
        for i in range(4, 60):
            diagonal = ([1] + [0] * i) * (i - 1) + [1]
            assert farmer(diagonal, i, 2) == diagonal

        #  takes ages
        #  assert farmer(grid_512_512_diagonal, 512, 1) == grid_512_512_diagonal
        #  assert farmer(grid_512_512_diagonal, 512, 14) == grid_512_512_diagonal
        #  assert farmer(grid_512_512_diagonal, 512, 100) == grid_512_512_diagonal
        #  assert farmer(grid_512_512_diagonal, 512, 400) == grid_512_512_diagonal


class TestSplitter():

    def test_zeros(self):
        assert split_into_strips(grid_8_8_zeros, 8, 8, 1) == strips1_8_8_zeros
        assert split_into_strips(grid_8_8_zeros, 8, 8, 2) == strips2_8_8_zeros
        assert split_into_strips(grid_8_8_zeros, 8, 8, 3) == strips3_8_8_zeros
        assert split_into_strips(grid_8_8_zeros, 8, 8, 4) == strips4_8_8_zeros
        assert split_into_strips(grid_8_8_zeros, 8, 8, 5) == strips4_8_8_zeros

    def test_half_and_half(self):
        assert split_into_strips(grid_8_8_half_and_half, 8, 8, 2) == strips2_8_8_half_and_half

    def test_range(self):
        assert split_into_strips(grid_8_8_range, 8, 8, 1) == strips1_8_8_range
        assert split_into_strips(grid_8_8_range, 8, 8, 2) == strips2_8_8_range
        assert split_into_strips(grid_8_8_range, 8, 8, 3) == strips3_8_8_range
        assert split_into_strips(grid_8_8_range, 8, 8, 4) == strips4_8_8_range
