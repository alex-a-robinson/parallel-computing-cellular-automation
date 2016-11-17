#ifndef UTILS_H_
#define UTILS_H_

int compare_arrays(unsigned int a[], unsigned int b[], unsigned int n);
void print_array(unsigned int array[], unsigned int n);
void print_bits(unsigned int num);
void print_bits_array(unsigned int array[], unsigned int n);
unsigned int array_to_bits(unsigned int array[], unsigned int n);
void print_strips_as_grid(unsigned int worker_strips[workers][MAX_INTS_IN_STRIP], unsigned int working_strip_height, unsigned int workers, unsigned int ints_in_row);

#endif
