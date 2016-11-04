#!/usr/bin/env python3

from utils import display
from grids import alive, dead
import grids
from sys import exit

def split_into_strips(grid, width, height, strip_size):
    strips = []

    # only one worker
    if height == strip_size:
        return [grid[(height-1) * width:] + grid + grid[:width]]

    # multiple workers
    for i in range(0, height, strip_size):
        grid_start_index = i * width
        grid_stop_index = (((i + strip_size + 2) % height) * width - 1 ) % (width*height) +1

        if height != strip_size and i % (height - strip_size) == 0 and i != 0:  #last
            strip = grid[grid_start_index:]
            strip += grid[0 : grid_stop_index]
        else:
            strip = grid[grid_start_index : grid_stop_index]

        strips.append(strip)

    return strips

def farmer(grid, width=8, height=8, num_of_workers=2):
    updated_grid = []
    strip_size = height // num_of_workers #TODO test if ceiling instead of flooring is better here
    strips = split_into_strips(grid, width, height, strip_size)
    for i in range(num_of_workers):
        updated_strip = worker(strips[i], strip_size+2, width)

        if num_of_workers != 1 and i == num_of_workers - 1: # last needs partial prepend
            updated_grid = updated_strip[(strip_size-1)*width:] + updated_grid + updated_strip[:(strip_size-1)*width]
        else: # all others can just append
            updated_grid += updated_strip

    return updated_grid

def worker(strip, height=8, width=8):
    '''Given a strip with lines either side returns the new values of the
       new values of the strip'''
    updated_strip = []
    for i in range(0, height-2):
        line_group = strip[i*width:(i+3)*width]
        updated_strip += calc_line(line_group)
    return updated_strip

def calc_line(line_group):
    '''Given three lines returns the new values of the centre line'''
    lg = line_group # Shortcut
    updated_line = []
    lw = len(line_group) // 3
    for i in range(lw):
        cell_group = [lg[i], lg[(i+1) % lw], lg[(i+2) % lw],
                 lg[i+lw], lg[(i+1) % lw + lw], lg[(i+2) % lw + lw],
                 lg[i+lw*2], lg[(i+1) % lw + lw*2], lg[(i+2) % lw + lw*2]]

        if i == lw - 1: # last needs wrapping prepend
            updated_line = [calc_cell(cell_group)] + updated_line
        else: # append
            updated_line = updated_line + [calc_cell(cell_group)]
    return updated_line

def calc_cell(cell_group):
    '''Given 9 cells returns the new value of the middle cell'''
    cell = cell_group[4]
    #return cell #TODO remove
    alive_neighbours = sum(cell_group[0:4] + cell_group[5:])
    if alive_neighbours < 2 or alive_neighbours > 3:
        return dead
    if alive_neighbours == 2:
        return cell
    if alive_neighbours == 3:
        return alive

if __name__ == '__main__':
    display(farmer(farmer(grids.grid_8_8_glider_1)))
