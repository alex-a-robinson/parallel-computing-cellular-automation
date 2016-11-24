#ifndef IMAGE_PROCESSING_H_
#define IMAGE_PROCESSING_H_


#ifndef CONSTANTS_H_



void read_image(char filename[], client interface reader_farmer_if reader_farmer,  client output_gpio_if led);

void write_image(char filename[], client interface farmer_writer_if farmer_writer, client output_gpio_if led);

#endif /* IMAGE_PROCESSING_H_ */
