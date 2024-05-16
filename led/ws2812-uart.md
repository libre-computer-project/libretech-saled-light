# WS2812 LED via UART

[WS2812](ws2812.md)

## UART

* WS2812 codes are 3 bits, 0b110 for 1 or 0b100 for 0
* 800K/s WS2812 codes is 2.4Mbit so baud rate should be set to 2.5Mbit
* 3 WS2812 codes can be represented by a 7-bit UART packet with 1 stop bit
* UART start and stop bits feign as MSB or LSB of WS2812 code
* UART 7-bit mode read bytes from LSB with the 8th MSB bit ignored

## Hardware Requirement

* UART hardware must support 7-bit UART packet with single stop bit
* UART default is idle high so internal or external inverter needed

## IO

### LED Data

* 72-bits per LED
* 8 x 9-bit packets
* 1_01_01_0

### Inverted LED Data

* 72-bits per LED
* 8 x 9-bit packets
* 0_10_10_1

### UART Input Data MSB

* 64-bits per LED
* 8 x 8-bit packets
* _10_10_X

### UART Input Data LSB

* 64-bits per LED
* 8 x 8-bit packets
* X_01_01_
