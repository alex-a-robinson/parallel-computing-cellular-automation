#include "constants.h"

// Returns an int of the bit value

unsigned int get_bit(unsigned int array[], int index) {
	int array_index = index / INT_SIZE;
	int rel_index = index % INT_SIZE;
	int shift_amount = INT_SIZE - rel_index-1;
	return (array[array_index] & (1 << shift_amount)) >> shift_amount;
}
