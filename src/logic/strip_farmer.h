#ifndef STRIP_FARMER_H_
#define STRIP_FARMER_H_

uint calc_cell(uint index, uint strip[], uint width, uint ints_in_row);
void worker(int id, server interface worker_farmer wf_i);
void farmer(int id, client interface worker_farmer wf_i[workers], static const uint workers);

#endif
