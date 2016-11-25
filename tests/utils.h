#ifndef TEST_UTILS_H_
#define TEST_UTILS_H_

#include <stdio.h>
#include "constants.h"

int compare_arrays(unsigned int a[], unsigned int b[], unsigned int n);

void print_int_as_bits(unsigned int num) ;

void print_bits_array(unsigned int array[], unsigned int n);

void print_array(unsigned int array[], unsigned int n);

void print_strips_as_grid(unsigned int worker_strips[workers][MAX_INTS_IN_STRIP], unsigned int working_strip_height, unsigned int workers, unsigned int ints_in_row);

#endif
