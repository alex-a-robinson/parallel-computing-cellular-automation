#ifndef CONTROLS_H_
#define CONTROLS_H_


void orientation_control(client interface i2c_master_if i2c, client interface farmer_orientation_control foc, client output_gpio_if led);
void button_control(client interface farmer_button_control fbc, client input_gpio_if button_1, client input_gpio_if button_2);

#endif /* CONTROLS_H_ */
