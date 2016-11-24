#ifndef IMAGE_PROCESSING_H_
#define IMAGE_PROCESSING_H_

#include "gpio.h"
#include "logic/farmer_interfaces.h"

void image_reader(char filename[], client interface reader_farmer_if reader_farmer, client output_gpio_if led);

void image_writer(char filename[], server interface farmer_writer_if farmer_writer, client output_gpio_if led);

#endif /* IMAGE_PROCESSING_H_ */
