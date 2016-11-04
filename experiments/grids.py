alive = 1
dead = 0
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
line_4_1_zeros = [0] * 4

''' Line Groups '''
line_group_8_3_zeros = [0] * 24
line_group_8_3_ones  = [1] * 24
line_group_8_3_range = list(range(24))
line_group_4_3_zeros = [0] * 12
line_group_4_3_ones  = [1] * 12
line_group_4_3_range = list(range(12))
line_group_8_3_zeros_centre_ones = [0] * 8 + [1] * 8 + [0] * 8
line_group_8_3_ones_centre_zeros = [1] * 8 + [0] * 8 + [1] * 8

# Strips of alive, dead, alive, ..., expected result should be all alive
line_group_8_3_strips = [0, 1] * 12
line_group_8_3_strips_inverse = [1, 0] * 12

# Alive, Dead, Alive ... along top and bottom with middle all dead,
# expected result should be checkerboard
line_group_8_3_strips_centre_zeros = [1, 0] * 4 + [0] * 8 + [1, 0] * 4

# Checkerboard, Alive, Dead, Alive ..., expected result should be inverse
line_group_8_3_checker_board = [1, 0] * 4 + [0, 1] * 4 + [1, 0] * 4
line_group_8_3_checker_board_inverse = [0, 1] * 4 + [1, 0] * 4 + [0, 1] * 4




''' Strips '''
strips1_8_8_zeros = [[0] * 80]
strips2_8_8_zeros = [[0] * 48] * 2
strips3_8_8_zeros = [[0] * 40 , [0] * 40 , [0] * 32]
strips4_8_8_zeros = [[0] * 32] * 4

# shortcut
def _lr(*args):
    return list(range(*args))

strips1_8_8_range = [_lr(56,64)+_lr(64) +_lr(8)]
strips2_8_8_range = [_lr(0,48) , _lr(32,64) + _lr(16)]
strips3_8_8_range = [_lr(0,40), _lr(24,64) , _lr(48,64)+_lr(16)]
strips4_8_8_range = [_lr(32), _lr(16,48), _lr(32,64), _lr(48,64)+_lr(0,16)]


strips2_8_8_half_and_half = [[0]*32 + [1]*16 , [1]*32 + [0]*16]





''' Grids '''
grid_8_8_range = list(range(64))
grid_8_8_zeros = [0] * 64
grid_8_8_ones  = [1] * 64
grid_8_8_half_and_half  = [0] * 32 + [1] * 32
grid_8_8_alternating = 4*(line_8_1_alternating + line_8_1_alternating_inverse)
grid_8_8_alternating_inverse = 4*(line_8_1_alternating_inverse + line_8_1_alternating)
grid_8_8_strips = [0, 1] * 32
grid_8_8_strips_inverse = [1, 0] * 32


grid_8_8_editable = [
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0
]

''' loads of gliders'''
grid_8_8_glider_1 = [
    1, 0, 0, 0, 0, 0, 0, 0,
    0, 1, 1, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
]
grid_8_8_glider_2 = [
    0, 1, 0, 0, 0, 0, 0, 0,
    0, 0, 1, 0, 0, 0, 0, 0,
    1, 1, 1, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
]
grid_8_8_glider_3 = [
    0, 0, 0, 0, 0, 0, 0, 0,
    1, 0, 1, 0, 0, 0, 0, 0,
    0, 1, 1, 0, 0, 0, 0, 0,
    0, 1, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
]
grid_8_8_glider_4 = [
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 1, 0, 0, 0, 0, 0,
    1, 0, 1, 0, 0, 0, 0, 0,
    0, 1, 1, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
]
