def display(grid, width=8):
    '''Display a grid'''
    height = len(grid) // width
    for h in range(height):
        print(grid[h*width:(h+1)*width])
