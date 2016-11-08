
#include <stdio.h>
#include <math.h>


int calc_cell(int cell_group[9]){
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