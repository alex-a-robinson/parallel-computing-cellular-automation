#ifndef CONTROLS_H_
#define CONTROLS_H_


void orientation_control(client interface i2c_master_if i2c, client interface farmer_orientation_if farmer_orientation, client output_gpio_if led);
void button_control(client interface farmer_button_if farmer_button, client input_gpio_if button_1, client input_gpio_if button_2);

#endif /* CONTROLS_H_ */
