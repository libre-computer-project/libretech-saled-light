# WS2812 LED via SPI

[WS2812](ws2812.md)

## SPI

* WS2812 codes are 3 bits, 0b110 for 1 or 0b100 for 0
* 800K/s WS2812 codes is 2.4Mbit so SPI clock frequency should be set to between 2.1 and 2.8MHz
* SPI MOSI should be pull-down when idle
* SPI controllers can be 8/16/32/64-bit words with potential idle between words

## Hardware Requirement

* SPI MOSI can be idle-high so internal or external pull-down or inverter needed

## IO

### LED Data

* 72-bits per LED
* 8 x 9-bit packets
* 1_01_01_0

### Inverted LED Data

* 72-bits per LED
* 8 x 9-bit packets
* 0_10_10_1
