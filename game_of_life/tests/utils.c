int compare_arrays(uint a[], uint b[], uint n) {
    for (int i = 0 ; i < n ; i++) {
        //TODO: add 2d functionality
        if (a[i] != b[i]) {
            return 0;
        }
    }
    return 1;
}

void print_array(uint array[], uint n) {
    for (uint i = 0 ; i < n ; i++) {
        //TODO add 2d fucnitonality
        printf("%i", array[i]);
    }
    printf("\n");
}

void print_bits(uint num) {
    for (uint i=0 ; i<INT_SIZE; i++){
        printf("%i", (num & (1<<INT_SIZE-i-1)) ? 1 : 0);
    }
    printf("\n");
}

uint array_to_bits(uint array[], uint n){
	uint bits = 0;
	for(uint i=0 ; i<n ; i++){
		bits |= ((array[i]?1:0) << i);
	}
	return bits;
}

//uint alternate_columns_array[32] = {0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1};
//printf("%i", array_to_bits(alternate_columns_array));
