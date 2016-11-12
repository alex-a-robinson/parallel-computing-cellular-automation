#include <stdio.h>
#include "constants.h"
//#include "utils.c"

// Returns an int of the bit value
uint get_bit(uint array[], uint index) {
	int array_index = index / INT_SIZE;
	int rel_index = index % INT_SIZE;
	int shift_amount = INT_SIZE - rel_index-1;
	return (array[array_index] & (1 << shift_amount)) >> shift_amount;
}

// Finds neighbours, sums and returns new value
uint calc_cell(uint index, uint strip[], uint width, uint height) {
	uint sum = 0;

	// TODO: Opptimise with static indexs
	for (int r=-1; r < 2; r++) {
		uint row_scaler = (index / width + r) * width;
		for (int c=-1; c < 2; c++) {
			uint neighbour_index = ((index + c) % width + row_scaler) % (width*height);
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




 void worker(uint grid[], uint updated_strip[], uint start_index, uint number_of_cells, uint width, uint height) {
    //Given a strip with lines either side returns the new values of the new values of the strip
    for (uint i = 0; i < number_of_cells; i++ ){
		printf("%i-%i ",i, calc_cell((i+start_index) % (width*height), grid, width, height));
		 //TODO updated_strip[i] = calc_cell((i+start_index) % (width*height), grid, width, height);
	 }

 }


 void farmer(uint grid[], const uint width, const uint height, const uint workers_available) {
    // if workers_available == 1: //TODO: needed??
    //     return [grid[(height - 1) * width:] + grid + grid[:width]]

     uint strip_size = height / workers_available + ((height % workers_available)?1:0);
     uint workers_required = height / strip_size + ((height % strip_size)?1:0);
	 //uint cells_in_strip = width*strip_size;

	 //uint updated_strips[4][32*4]; // TODO: change to  [workers_required][cells_in_strip]
	 for (uint i=0 ; i < workers_required ; i++){ //TODO make par
		 // worker(grid, updated_strips[i], i * strip_size * width, strip_size * width, width, height);
	 }//TODO: start channels as arays aren't working


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
