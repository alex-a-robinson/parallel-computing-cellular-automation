#include <stdio.h>
#include "constants.h"

int compare_arrays(unsigned int a[], unsigned int b[], unsigned int n) {
    for (int i = 0; i < n; i++) {
        //TODO: add 2d functionality
        if (a[i] != b[i]) {
            return 0;
        }
    }
    return 1;
}

void print_int_as_bits(unsigned int num) {
    for (int i=0 ; i<INT_SIZE; i++){
        printf("%i", (num & (1<<(INT_SIZE-i-1))) ? 1 : 0);
    }
}

void print_bits_array(unsigned int array[], unsigned int n) {
    for (int i = 0; i < n; i++) {
        //TODO add 2d fucnitonality
        print_int_as_bits(array[i]);
        printf("\n");
    }
}

void print_array(unsigned int array[], unsigned int n) {
    for (int i = 0; i < n; i++) {
        //TODO add 2d fucnitonality
        printf("%i", array[i]);
    }
    printf("\n");
}

unsigned int array_to_bits(unsigned int array[], unsigned int n){
	unsigned int bits = 0;
	for(unsigned int i=0 ; i<n ; i++){
		bits |= ((array[i]?1:0) << n-i-1); //fills from right to left
	}
	return bits;
}

void print_strips_as_grid(unsigned int worker_strips[workers][MAX_INTS_IN_STRIP], unsigned int working_strip_height, unsigned int workers, unsigned int ints_in_row) {
    for (int worker_index=0; worker_index < workers; worker_index++) {
        for (int row_index=1; row_index <= working_strip_height; row_index++) {
            for (int int_index=0; int_index < ints_in_row; int_index++){
                print_int_as_bits(worker_strips[worker_index][row_index*ints_in_row + int_index]);
                printf("   [%i]%i", worker_index, row_index*ints_in_row + int_index);
            }
            printf("\n");
        }
    }
}
