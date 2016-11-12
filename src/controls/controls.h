#ifndef CONTROLS_H_
#define CONTROLS_H_


void orientation_control(client interface i2c_master_if i2c, chanend toDist);
void button_control(client input_gpio_if button_1, client input_gpio_if button_2,
          client output_gpio_if led_green, client output_gpio_if rgb_led_blue,
          client output_gpio_if rgb_led_green, client output_gpio_if rgb_led_red);

#endif /* CONTROLS_H_ */
