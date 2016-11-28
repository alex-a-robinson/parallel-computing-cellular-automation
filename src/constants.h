#ifndef CONSTANTS_H_
#define CONSTANTS_H_

// Type Constants
#define INT_SIZE 32 // 32 bit ints
#define MAX_INTS_IN_STRIP  3000 // TODO Optimise for memory, 512x512 grid for 4 workers is 2080
#define MAX_WORKERS 4

// Image Constants
#define MAX_WIDTH 1024 // Image height
#define MAX_HEIGHT 1024 // Image width

// Orientation
#define FXOS8700EQ_I2C_ADDR 0x1E  // register addresses for orientation
#define FXOS8700EQ_XYZ_DATA_CFG_REG 0x0E
#define FXOS8700EQ_CTRL_REG_1 0x2A
#define FXOS8700EQ_DR_STATUS 0x0
#define FXOS8700EQ_OUT_X_MSB 0x1
#define FXOS8700EQ_OUT_X_LSB 0x2
#define FXOS8700EQ_OUT_Y_MSB 0x3
#define FXOS8700EQ_OUT_Y_LSB 0x4
#define FXOS8700EQ_OUT_Z_MSB 0x5
#define FXOS8700EQ_OUT_Z_LSB 0x6

// Controls
#define TILTED_ANGLE 40 // Pause/Play threshold angle, 40 degrees

#endif /* CONSTANTS_H_ */
