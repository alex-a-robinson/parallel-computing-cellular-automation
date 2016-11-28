#include "constants.h"

// Returns an int of the bit value

/* Returns value of a cell whih is packed into an array of ints
 *
 * Params:
 *   unsigned int array[]: Array of ints (which are packed cells)
 *   int cell_index: Index of the cell
 *
 * Returns:
 *   unsigned int: The cell value
 */
unsigned int get_bit(unsigned int array[], int cell_index) {
    // Calc the index of the int we need to work on,
    // then shift and unshift to get value
    int int_index = cell_index / INT_SIZE;
    int shift_amount = INT_SIZE - 1 - (cell_index % INT_SIZE);
    return (array[int_index] & (1 << shift_amount)) >> shift_amount;
}

int ceil_div(int a, int b) { return (a / b) + ((a % b) ? 1 : 0); }

/* Packs an array of cells into an array
 *
 * Params:
 *   unsigned int array[]: Array of cells
 *   unsigned int size: Size of array
 *
 * Returns:
 *   unsigned int: A int each bit represents a cell value from the array
 */
unsigned int array_to_bits(unsigned int array[], unsigned int size) {
    // Initiate int to work on
    unsigned int bits = 0;

    // For each cell in the array, shift value into int
    for (unsigned int i = 0; i < size; i++) {
        bits |= ((array[i] ? 1 : 0) << size - i - 1); // fills from right to left
    }
    return bits;
}

/* Unpakcs an int into an array
 *
 * Params:
 *   unsigned int num: Int to unpack
 *   char bitstring[]: Reference to array to unpack into
 */
void int_to_bitstring(unsigned int num, char bitstring[]) {
    // For each bit in the int, shift to get value and store in bitstring
    for (int i = 0; i < INT_SIZE; i++) {
        bitstring[i] = (num & (1 << (INT_SIZE - i - 1))) ? '1' : '0';
    }
    bitstring[INT_SIZE] = '\0';
}
