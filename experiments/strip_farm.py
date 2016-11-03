#!/usr/bin/env python3

# 1 = Alive
# 2 = Dead

import math

grid = [
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0
]

def farmer(grid, width=8, height=8, num_of_workers=4):
    updated_grid = []
    channels = []
    workers = [worker] * num_of_workers
    strip_size = height // num_of_workers

    for i in range(0,height,strip_size):
        strip = grid[i * width : (((i + strip_size + 2) % height) * width - 1) % (width*height)]
        #display(workers[i](strip, strip_size+2, width))

        # updated_grid[(i + 1) * width : (((i + strip_size + 1) % height) * width - 1) % (width*height)] = workers[i](strip, strip_size+2, width)
        updated_grid += worker(strip, strip_size+2, width)

    return updated_grid

def worker(strip, height=8, width=8):
    updated_strip = []
    for i in range(0, height-2):
        line_group = strip[i*width:(i+3)*width]
        updated_strip += calc_line(line_group)  #[(i+1)*width:(i+2)*width-1]
    return updated_strip

def calc_line(line_group):
    lg = line_group # Shortcut
    updated_line = []
    lw = len(line_group) // 3
    for i in range(lw):
        cell_group = [lg[i], lg[(i+1) % lw], lg[(i+2) % lw],
                 lg[i+lw], lg[(i+1) % lw + lw], lg[(i+2) % lw + lw],
                 lg[i+lw*2], lg[(i+1) % lw + lw*2], lg[(i+2) % lw + lw*2]]

        updated_line.append(calc_cell(cell_group))

    return updated_line

# Group is a 3x3 array, returns new value of middle cell
def calc_cell(cell_group):
    cell = cell_group[4]
    return cell
    alive_neighbours = sum(cell_group[0:4] + cell_group[5:])
    if alive_neighbours < 2 or alive_neighbours > 3:
        return 0
    if alive_neighbours == 2:
        return cell
    if alive_neighbours == 3:
        return 1

def display(grid, width=8):
    height = len(grid) // width
    for h in range(height):
        print(grid[h*width:(h+1)*width])

grid = list(range(64))
display(farmer(grid))
#display(worker(list(range(64))))
