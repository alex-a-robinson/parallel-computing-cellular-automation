# coms20001-cellular-automaton-assignment
COMS20001 Concurrent Computing term 1 assignment

## Google Drive:
https://drive.google.com/drive/folders/0B8r-7anzk7gQNFFUX0MwR1Fla0E?usp=sharing

Thoughts and Diary:
https://docs.google.com/document/d/1_RFqflIu9wtYERPC07vNm1GZtXkS0ZIZHcadgs6FLnY/edit?usp=sharing


## Communication
Farmer (also controls LEDs):

* orientation_control (foc)
  * < pause/play
* read_image (rif)
  * > start_read
  * < data, read_done
* write_image (wif)
  * > data, start_write
  * < write_done
* button_control (fbc)
  * < start_read, start_write
* worker (fw)
  * > data, tick
  * < data

farmer:
int pause = 0;
int buffer_data[strip_size * width / INT_SIZE];

// TODO need to create buffer to hold everything
// Need to get width/height from image to calc
// strip size

switch {
    case foc.pause(int x):
        pause = x;
        break;
    case fbc.start_read(int x):
        fir.start_read(); // this is a [[notification]]
        break;
    case fbc.start_write(int x):
        // TODO light LED
        while data {
            wif.write(data);
        }
        break;
    case wif.write_done(): // this is a [[notification]]
        // TODO unlight LED
        exit(0);
        break;
    case fir.read_done(int x):
        // TODO unlight LED
        break;
    case fir.data(int i, int data):
        // TODO give data to someone
        buffer[i] = data;
        fw[i].data_ready();
        break;
    case fw[int i].get_data() -> int data:
        data = buffer[i];
        break;
    case fw[int i].result(int data):
        buffer[i] = data;
        break;
}
