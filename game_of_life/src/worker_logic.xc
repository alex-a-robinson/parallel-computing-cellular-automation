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
uint calc_cell(uint index, uint strip[], const static uint width) {
	uint sum = 0;

	// TODO: Opptimise with static indexs
	for (int r=-1; r < 2; r++) {
		uint row_scaler = (index / width + r) * width;
		for (int c=-1; c < 2; c++) {
			uint neighbour_index = (index + c) % width + row_scaler;
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

/*
void set_bit(uint array[], uint index, uint val) {
	if (val) {
		array[index / INT_SIZE] |= (1 << (INT_SIZE - (index % INT_SIZE)) - 1);
	} else {
		array[index / INT_SIZE] &= (0 << (INT_SIZE - (index % INT_SIZE)));
	}
}
*/

/*

 void worker(int strip[], static const uint strip_size, static const uint width) {
    //Given a strip with lines either side returns the new values of the new values of the strip
    uint updated_strip [strip_size*width];
    for (i=0 ; i<strip_size ; i++ ){
        line_group = strip[i * width:(i + 3) * width];
        updated_strip += calc_line(line_group);

	}
 }

 */
