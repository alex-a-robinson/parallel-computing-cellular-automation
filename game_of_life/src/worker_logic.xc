
#include <stdio.h>
#include <math.h>


int calc_cell(int cell_group[9]) {
    //Given 9 cells returns the new value of the middle cell
    int alive_neighbours = 0;
    for(int i=0 ; i<9 ; i++) {
    	alive_neighbours += (i!=4) ? cell_group[i] : 0;
    }
    	 
    switch(alive_neighbours) {
    	case 0 :
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
 
 
 void calc_line(int line_group[], const static int width) {
 //Given three lines returns the new values of the centre line
 	//assert (width * 3 == size_of(linegroup)/sizeof(linegroup[0]));
    int updated_line[width];
    for (int i=0 ; i<width ; i++) {
        int cell_group[9] = {line_group[i], line_group[(i + 1) % width], line_group[(i + 2) % width],
                      line_group[i + width], line_group[(i + 1) % width + width], line_group[(i + 2) % width + width],
                      line_group[i + width * 2], line_group[(i + 1) % width + width * 2], line_group[(i + 2) % width + width * 2]};
		
        updated_line[(i+1) % width]= calc_cell(cell_group);
    }
    
 }