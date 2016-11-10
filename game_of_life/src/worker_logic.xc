#include <stdio.h>

const static int INT_SIZE = sizeof(unsigned int)*8;

#include <utils.c>


// Returns an int of the bit value
uint get_bit(uint array[], uint index) {
	int array_index = index / INT_SIZE;
	int rel_index = index % INT_SIZE;
	int shift_amount = INT_SIZE - rel_index-1;
	return (array[array_index] & (1 << shift_amount)) >> shift_amount;
}

// Finds neighbours, sums and returns new value
uint calc_cell(uint index, uint strip[], uint width) {
	uint sum = 0;

	// TODO: Opptimise with static indexs
	for (int r=-1; r < 2; r++) {
		uint row_scaler = (index / width + r) * width;
		for (int c=-1; c < 2; c++) {
			uint neighbour_index = ((index + c) % width + row_scaler)) % (width*height);
			if (!(r == 0 && c == 0)) {
				sum += get_bit(strip, neighbour_index);
			}
		}
	}
	switch(sum) {
    	case 0: // All dead, cell dies
			return 0;
    	case 1: // Only one alive, cell dies
    		return 0;
    	case 2: // 2 alive, cell maintains
    		return get_bit(strip, index);
    	case 3: // 3 alive, cell born
    		return 1;
    	default: // more then 3, dies of overpoluation
    		return 0;
    }
}




 void worker(uint grid[], uint updated_strip[], uint start_index, uint number_of_cells, uint height, uint width) {
    //Given a strip with lines either side returns the new values of the new values of the strip
    for (uint i = start_index; i < start_index + number_of_cells; i++ ){
		 updated_strip = calc_cell(start_index % (width*height), grid, width);

 }

 void farmer(uint grid[], uint strips[]]; uint width, uint height, uint workers_available) {
     if workers_available == 1:
         return [grid[(height - 1) * width:] + grid + grid[:width]]

     strips = []
     strip_size = math.ceil(height / workers_available)
     workers_required = math.ceil(height / strip_size)

     for i in range(0, height, strip_size):
         last = (i >= (height - strip_size))

         # Alter the strip size if workers dosent perfectly devide height
         if last and height % strip_size != 0:
             strip_size = height % strip_size

         grid_start_index = i * width
         grid_stop_index = (((i + strip_size + 2) % height) * width - 1) % (width * height) + 1

         if grid_start_index >= grid_stop_index:
             strip = grid[grid_start_index:] + grid[:grid_stop_index]
         else:
             strip = grid[grid_start_index: grid_stop_index]
         strips.append(strip)

}

/*
void set_bit(uint array[], uint index, uint val) {
	if (val) {
		array[index / INT_SIZE] |= (1 << (INT_SIZE - (index % INT_SIZE)) - 1);
	} else {
		array[index / INT_SIZE] &= (0 << (INT_SIZE - (index % INT_SIZE)));
	}
}
*/



 */
