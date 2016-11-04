alive = 1
dead = 0

''' Grids '''
grid_8_8_range = list(range(64))
grid_8_8_zeros = [0] * 64
grid_8_8_ones  = [1] * 64
grid_editable = [
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0
]

''' Cell Groups '''
cell_group_zeros = [0] * 9
cell_group_ones  = [1] * 9
cell_group_range = list(range(9))
cell_group_centre_alive = [0, 0, 0, 0, 1, 0, 0, 0, 0]
cell_group_no_change_dead = [0, 1, 0, 0, 0, 0, 0, 1, 0]
cell_group_no_change_alive = [0, 1, 0, 0, 1, 0, 0, 1, 0]
cell_group_born = [0, 1, 0, 0, 0, 1, 0, 1, 0]
cell_group_overpopulated = [0, 1, 1, 0, 1, 1, 0, 1, 0]

''' Lines '''
line_8_1_zeros = [0] * 8
line_8_1_ones  = [1] * 8
line_8_1_range = list(range(8))
line_8_1_alternating = [0, 1] * 4
line_8_1_alternating_inverse = [1, 0] * 4

''' Line Groups '''
line_group_8_3_zeros = [0] * 24
line_group_8_3_ones  = [1] * 24
line_group_8_3_range = list(range(24))
line_group_4_3_zeros = [0] * 12
line_group_4_3_ones  = [1] * 12
line_group_4_3_range = list(range(12))

# Expeccted
line_group_8_3_zeros_centre_ones = [0] * 8 + [1] * 8 + [0] * 8
line_group_8_3_ones_centre_zeros = [1] * 8 + [0] * 8 + [1] * 8

# Strips of alive, dead, alive, ..., expected result should be all alive
line_group_8_3_strips = [1, 0] * 12
line_group_8_3_strips_inverse = [0, 1] * 12

# Alive, Dead, Alive ... along top and bottom with middle all dead,
# expected result should be checkerboard
line_group_8_3_strips_centre_zeros = [1, 0] * 4 + [0] * 8 + [1, 0] * 4

# Checkerboard, Alive, Dead, Alive ..., expected result should be inverse
line_group_8_3_checker_board = [1, 0] * 4 + [0, 1] * 4 + [1, 0] * 4
line_group_8_3_checker_board_inverse = [0, 1] * 4 + [1, 0] * 4 + [0, 1] * 4
