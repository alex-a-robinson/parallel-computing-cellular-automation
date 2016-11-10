#!/usr/bin/env python3

from utils import display
import grids
from sys import exit
import math

dead = 0
alive = 1

def split_into_strips(grid, width, height, workers_available):

    # only one worker
    if workers_available == 1:
        return [grid[(height - 1) * width:] + grid + grid[:width]]

    strips = []
    strip_size = math.ceil(height / workers_available)
    workers_required = math.ceil(height / strip_size)

    for i in range(0, height, strip_size):
        last = (i >= (height - strip_size))

        # Alter the strip size if workers dosen't perfectly devide height
        if last and height % strip_size != 0:
            strip_size = height % strip_size

        grid_start_index = i * width
        grid_stop_index = (((i + strip_size + 2) % height) * width - 1) % (width * height) + 1

        if grid_start_index >= grid_stop_index:
            strip = grid[grid_start_index:] + grid[:grid_stop_index]
        else:
            strip = grid[grid_start_index: grid_stop_index]
        strips.append(strip)

    return strips


def farmer(grid, width, num_of_workers=2, steps=1):
    assert len(grid) % width == 0
    height = len(grid) // width

    for step in range(steps):
        updated_grid = [2] * width * height
        strips = split_into_strips(grid, width, height, num_of_workers)
        num_of_workers = len(strips)

        # each step calculated by parralell workers
        for worker_num in range(num_of_workers):  # will be par
            strip = strips[worker_num]
            base_strip_size = (len(strips[0]) // width) - 2
            strip_size = (len(strip) // width) - 2
            updated_strip = worker(strip, strip_size, width)

            for cell_index in range(len(updated_strip)):
                base = worker_num * base_strip_size * width
                if num_of_workers != 1:
                    base += width
                update_index = (base + cell_index) % (width * height)

                updated_grid[update_index] = updated_strip[cell_index]

        grid = updated_grid

    display(grid)

    return grid


def worker(strip, strip_size, width):
    '''Given a strip with lines either side returns the new values of the
       new values of the strip'''
    updated_strip = []
    for i in range(0, strip_size):
        line_group = strip[i * width:(i + 3) * width]
        updated_strip += calc_line(line_group)
    return updated_strip


def calc_line(line_group):
    '''Given three lines returns the new values of the centre line'''
    lg = line_group  # Shortcut
    updated_line = []
    lw = len(line_group) // 3
    for i in range(lw):
        cell_group = [lg[i], lg[(i + 1) % lw], lg[(i + 2) % lw],
                      lg[i + lw], lg[(i + 1) % lw + lw], lg[(i + 2) % lw + lw],
                      lg[i + lw * 2], lg[(i + 1) % lw + lw * 2], lg[(i + 2) % lw + lw * 2]]

        if i == lw - 1:  # last needs wrapping prepend
            updated_line = [calc_cell(cell_group)] + updated_line
        else:  # append
            updated_line = updated_line + [calc_cell(cell_group)]
    return updated_line

def get_bit(data, index):
    return data >> index


def calc_cell(cell_group):
    '''Given 9 cells returns the new value of the middle cell
    000
    0-0
    000
    '''
    cell = cell_group[4]
    # return cell
    alive_neighbours = sum(cell_group[0:4] + cell_group[5:])
    if alive_neighbours < 2 or alive_neighbours > 3:
        return dead
    if alive_neighbours == 2:
        return cell
    if alive_neighbours == 3:
        return alive

if __name__ == '__main__':
    display(farmer(farmer(grids.grid_8_8_glider_1)))
