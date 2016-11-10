#include <stdio.h>
#include <math.h>

const static int INT_SIZE = sizeof(unsigned int)*8;


void slice_array(int incoming[], int outgoing[], int start_index, int end_index) {
	for (int i=start_index ; i<end_index ; i++) {
		outgoing[i-start_index] = incoming[i];
	}
}

int calc_cell(int cell_group) {
    //Given 9 cells returns the new value of the middle cell
    int alive_neighbours = 0;
    for(int i=0 ; i<9 ; i++) {
		int neighbour = (cell_group >> i) & 1;
    	alive_neighbours += (i!=4) ? neighbour : 0;
    }

    switch(alive_neighbours) {
    	case 0 :
			return 0;
    	case 1 :
    		return 0;
    	case 2 :
    		return cell_group & (1<<4);
    	case 3 :
    		return 1;
    	default :
    		return 0;
    }
 }



int get_bit(uint array[], int index) {
	return array[index / INT_SIZE] >> index % INT_SIZE;
}

void set_bit(uint array[], int index, int val) {
	array[index / INT_SIZE] |= ((val?1:0)<< (index % INT_SIZE));
}
/*
 void calc_line(int line_group[], int updated_line[], const static int width) {
 //Given three lines updates the new values of the centre line

	for (int i=0 ; i<width ; i++) {
        int cell_group[9] = {get_bit(line_group,i), get_bit(line_group,(i + 1) % width), get_bit(line_group,(i + 2) % width),
                      get_bit(line_group,i + width), get_bit(line_group,(i + 1) % width + width), get_bit(line_group,(i + 2) % width + width),
                      get_bit(line_group,i + width * 2), get_bit(line_group,(i + 1) % width + width * 2), get_bit(line_group,(i + 2) % width + width * 2)};
					  //TODO: change this to a bitfield
        set_bit(updated_line,(i+1) % width, calc_cell(cell_group));
    }
 }
*/

/*

 void worker(int strip[], static const int strip_size, static const int width) {
    //Given a strip with lines either side returns the new values of the new values of the strip
    int updated_strip [strip_size*width];
    for (i=0 ; i<strip_size ; i++ ){
        line_group = strip[i * width:(i + 3) * width];
        updated_strip += calc_line(line_group);

	}
 }

 */
