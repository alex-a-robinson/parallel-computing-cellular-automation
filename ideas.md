Strip swapper

# TODO
* create strip in each worker
* create new interfaces for farmers and workers
  * tick()
  * tock()
  * set(data, index)
  * get(index)
  * get_done() -> {data, index}
* create overlaps in farmers
* create swapping logic

# COMUNICATON LOGIC

def farmer:
    case read:
        while(read):
            case read.read_data(data, index):
                worker_to_set = ?
                index_to_set = ?
                workers[worker_to_set].set(data, index_to_set)
                # NOTE can also do overlaps here

    case write:
        # TODO

    while (workers_left):
        case workers[int id].tock():
            workers_left--

    for bottom in 2:
        for int_index in row:
            for id in workers:
                worker[id].get(int_index)

            workers_left = workers
            while(workers_left):
                case worker[int id].get_done() -> {data, index}:
                    if (top):
                        rel_index = ?
                        worker[id--].set(data, rel_index)
                        workers_left--;




# ----

Farmer:
top_overlap[max_workers] = [
    w0,
    w1,
    w2,
    w3
]

bottom_overlap[max_workers] = [
    w0,
    w1,
    w2,
    w3
]

w0_strip = [
    top_overlap,
    first_working_row,
    working_rows,
    bottom_working_row,
    bottom_overlap
]

w0[top_overlap] = w3[bottom_working_row]
w0[bottom_overlap] = w1[top_working_row]

# on read
while(data_to_read):
    case reader.read_data(data, grid_index):
        worker_to_give_to = # TODO calc
        worker.init_data(data, strip_index) <- offset for controls
        is overlap?:idea
            top_overlap[?][strip_index % ints_in_row] = data
            bottom_overlap[?][strip_index % ints_in_row] = data

while (1):
    # Hand out overlaps
    for id in workers:
        worker.overflows(overflow_top, overflow_bottom)
        worker.tick() # <- Tell worker to start work

    # Wait until all done
    workers_left = workers_needed
    while (!workers_left):
        case workers[int id].tock():
            workers_left--

    # Swap neighbour rows
    prev_bottom = bottom_overlap[0]
    first_top = top_overlap[0]
    second_top = top_overlap[1]
    for id=1 in workers--:
        top_overlap[id] = prev_bottom
        prev_bottom = bottom_overlap[id]
        bottom_overlap[id] = top_overlap[id++]

    top_overlap[0] = bottom_overlap[workers]
    bottom_overlap[0] = second_top
    top_overlap[workers] = prev_bottom
    bottom_overlap[workers] = first_top

---

def worker:
    strip = [
        top_overlap,
        first_working_row,
        working_rows,
        bottom_working_row,
        bottom_overlap
    ]

    top_overlap = []
    bottom_overlap = []

    case farmer.init(top_overlap, bottom_overlap):
        top_overlap = top_overlap
        bottom_overlap = bottom_overlap

        # Copy into strip
        memcopy(top_overlap, strip)
        memcopy(bottom_overlap, strip)

    case farmer.tick():
        # Do work

        # Copy working rows to overlaps
        memcopy(strip[bottom_working_row], bottom_overlap)
        memcopy(strip[top_working_row], top_overlap)

        farmer.tock()
