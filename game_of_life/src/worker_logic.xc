#include <stdio.h>
#include <math.h>



void slice_array(int incoming[], int outgoing[], int start_index, int end_index) {
	for (int i=start_index ; i<end_index ; i++) {
		outgoing[i-start_index] = incoming[i];
	}
}

int calc_cell(int cell_group[9]) {
    //Given 9 cells returns the new value of the middle cell
    int alive_neighbours = 0;
    for(int i=0 ; i<9 ; i++) {
    	alive_neighbours += (i!=4) ? cell_group[i] : 0;
    }

    switch(alive_neighbours) {
    	case 0 :
			return 0;
    	case 1 :
    		return 0;
    	case 2 :
    		return cell_group[4];
    	case 3 :
    		return 1;
    	default :
    		return 0;

    }
 }


 void calc_line(int line_group[], int updated_line[], const static int width) {
 //Given three lines updates the new values of the centre line
    for (int i=0 ; i<width ; i++) {
        int cell_group[9] = {line_group[i], line_group[(i + 1) % width], line_group[(i + 2) % width],
                      line_group[i + width], line_group[(i + 1) % width + width], line_group[(i + 2) % width + width],
                      line_group[i + width * 2], line_group[(i + 1) % width + width * 2], line_group[(i + 2) % width + width * 2]};

        updated_line[(i+1) % width]= calc_cell(cell_group);
    }
 }

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
