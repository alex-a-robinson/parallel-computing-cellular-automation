#!/usr/bin/env python3

# 1 = Alive
# 2 = Dead

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

def farmer(grid):
    channels = []
    strip = grid[0:4*8-1]
    worker(strip)

def worker(strip, height=4, width=8):
    pass

def calc_line(line):
    updated_line = line
    lw = len(line) // 3
    for i in range(lw-1):
        group = [line[i], line[i+1], line[i+2 % lw],
                 line[i+lw], line[i+1+lw], line[(i+2) % lw + lw],
                 line[i+lw*2], line[i+1+lw*2], line[(i+2) % lw + lw*2]
                 ]
        print(group)

# Group is a 3x3 array, returns new value of middle cell
def calc_group(group):
    cell = group[4]
    alive_neighbours = sum(group[0:4] + group[5:])
    if alive_neighbours < 2 or alive_neighbours > 3:
        return 0
    if alive_neighbours == 2:
        return cell
    if alive_neighbours == 3:
        return 1

line = range(24)
calc_line(line)

#farmer(grid)
