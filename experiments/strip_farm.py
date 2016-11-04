#!/usr/bin/env python3

from utils import display
from grids import alive, dead
import grids

def farmer(grid, width=8, height=8, num_of_workers=2):
    updated_grid = []
    channels = []
    strip_size = height // num_of_workers

    for i in range(0,height,strip_size):

        grid_start_index = i * width
        grid_stop_index = (((i + strip_size + 2) % height) * width - 1 ) % (width*height) +1

        #print(i)
        #print(grid_start_index , grid_stop_index-1)
        #print((i + 1) * width , ((i + strip_size + 1) % height) * width)

        if i % (height - strip_size) == 0 and i != 0: #last
            strip = grid[grid_start_index : height * width]
            strip += grid[0 : grid_stop_index]

            display (strip)
            print("")
            from_worker = worker(strip, strip_size+2, width)
            display(from_worker) #TODO
            return []
            updated_grid = from_worker[(strip_size-1)*width:] + updated_grid + from_worker[:(strip_size-1)*width] # TODO fix output error??
        else:
            strip = grid[grid_start_index : grid_stop_index]
            updated_grid += worker(strip, strip_size+2, width)

    return updated_grid

def worker(strip, height=8, width=8):
    '''Given a strip with lines either side returns the new values of the
       new values of the strip'''
    updated_strip = []
    for i in range(0, height-2):
        line_group = strip[i*width:(i+3)*width]
        updated_strip += calc_line(line_group)  #[(i+1)*width:(i+2)*width-1]
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

        updated_line.append(calc_cell(cell_group))

    return updated_line

def calc_cell(cell_group):
    '''Given 9 cells returns the new value of the middle cell'''
    cell = cell_group[4]
    return cell #TODO remove
    alive_neighbours = sum(cell_group[0:4] + cell_group[5:])
    if alive_neighbours < 2 or alive_neighbours > 3:
        return dead
    if alive_neighbours == 2:
        return cell
    if alive_neighbours == 3:
        return alive

display(farmer(grids.grid_8_8_range))
