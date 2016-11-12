#include <stdio.h>
#include "../src/constants.h"

int compare_arrays(unsigned int a[], unsigned int b[], unsigned int n) {
    for (int i = 0; i < n; i++) {
        //TODO: add 2d functionality
        if (a[i] != b[i]) {
            return 0;
        }
    }
    return 1;
}

void print_array(unsigned int array[], unsigned int n) {
    for (int i = 0; i < n; i++) {
        //TODO add 2d fucnitonality
        printf("%i", array[i]);
    }
    printf("\n");
}

void print_bits(unsigned int num) {
    for (int i=0 ; i<INT_SIZE; i++){
        printf("%i", (num & (1<<(INT_SIZE-i-1))) ? 1 : 0);
    }
    printf("\n");
}

unsigned int array_to_bits(unsigned int array[], unsigned int n){
	unsigned int bits = 0;
	for(unsigned int i=0 ; i<n ; i++){
		bits |= ((array[i]?1:0) << i);
	}
	return bits;
}

//unsigned int alternate_columns_array[32] = {0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1};
//printf("%i", array_to_bits(alternate_columns_array));
