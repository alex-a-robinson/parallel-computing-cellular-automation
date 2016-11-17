//in farmer:
    for line in data:
        switch {
            case fwi.ready_for_data():
                fwi.data(line)
                break;
        }
    }
    switch {
        case fwi.ready_for_data(): //last line written
            fwi.end_of_data(); //- trigger leD
            sys.exit()
            break;
    }


//in write_image:
    while (1) {
        fwi.ready_for_data();
        switch {
            case fwi.data(int data):
                if !led:
                    light(led)
                write(data);
                fwi.ready_for_data();
            case end_of_data():
                unlight(led);
        }
    }

