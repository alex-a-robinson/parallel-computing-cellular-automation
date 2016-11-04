from grids import *
from strip_farm import calc_cell, calc_line, farmer

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

class TestFarmer():
    def test_alternating(self):
        assert farmer(grid_8_8_alternating) == grid_8_8_zeros
        assert farmer(grid_8_8_alternating_inverse) == grid_8_8_zeros

    def test_all_dead(self):
        assert farmer(grid_8_8_ones) == grid_8_8_zeros
        assert farmer(grid_8_8_zeros) == grid_8_8_zeros

    def test_strips(self):
        assert farmer(grid_8_8_strips) == grid_8_8_strips
        assert farmer(grid_8_8_strips_inverse) == grid_8_8_strips_inverse

    def test_glider(self):
        assert farmer(grid_8_8_glider_1) == grid_8_8_glider_2
        assert farmer(grid_8_8_glider_2) == grid_8_8_glider_3
        assert farmer(grid_8_8_glider_3) == grid_8_8_glider_4
