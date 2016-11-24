//in farmer:
    for line in data:
        switch {
            case farmer_writer.ready_for_data():
                farmer_writer.data(line)
                break;
        }
    }
    switch {
        case farmer_writer.ready_for_data(): //last line written
            farmer_writer.end_of_data(); //- trigger leD
            sys.exit()
            break;
    }


//in write_image:
    while (1) {
        farmer_writer.ready_for_data();
        switch {
            case farmer_writer.data(int data):
                if !led:
                    light(led)
                write(data);
                farmer_writer.ready_for_data();
            case end_of_data():
                unlight(led);
        }
    }

