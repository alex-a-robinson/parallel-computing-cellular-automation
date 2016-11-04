def display(grid, width=8):
    '''Display a grid'''
    assert type(grid) == list
    assert type(grid[0]) == int
    height = len(grid) // width
    for h in range(height):
        print(grid[h*width:(h+1)*width])
