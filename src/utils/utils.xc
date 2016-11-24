#include "constants.h"

// Returns an int of the bit value

unsigned int get_bit(unsigned int array[], int cell_index) {
    int int_index = cell_index / INT_SIZE;
    int shift_amount = INT_SIZE - 1 - (cell_index % INT_SIZE);
    return (array[int_index] & (1 << shift_amount)) >> shift_amount;
}

int ceil_div(int a, int b) { return (a / b) + ((a % b) ? 1 : 0); }

unsigned int array_to_bits(unsigned int array[], unsigned int n) {
    unsigned int bits = 0;
    for (unsigned int i = 0; i < n; i++) {
        bits |= ((array[i] ? 1 : 0) << n - i - 1); // fills from right to left
    }
    return bits;
}

void int_to_bitstring(unsigned int num, char bitstring[]) {
    for (int i = 0; i < INT_SIZE; i++) {
        bitstring[i] = (num & (1 << (INT_SIZE - i - 1))) ? '1' : '0';
    }
    bitstring[INT_SIZE] = '\0';
}
