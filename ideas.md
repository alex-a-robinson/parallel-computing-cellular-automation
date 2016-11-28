Strip swapper

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
    temp_top = top_overlap[0]
    temp_bottom = bottom_overlap[0]
    for id in workers--:
        top_overlap[id] = bottom_overlap[id++]
        bottom_overlap[id] = top_overlap[id++]
    top_overlap[workers] = temp_top
    bottom_overlap[workers] = temp_bottom



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
        memcopy(strip[bottom_working_row], top_overlap)
        memcopy(strip[top_working_row], bottom_overlap)

        farmer.tock()
