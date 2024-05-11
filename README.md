# SALED - Serially Addressed Light Emitting Diodes

## Design

The design utilizes 3 discrete concepts and 4 distinct component steps.

Concepts
* LED
* Panel
* Output

Component Steps
* Configuration
* Generation
* Conversion
* Buffering

### LED

LED IC being used. There are LED drivers which can be programmed in any language to read a framebuffer from STDIN and converted to the LED signaling for a specific bus and pushed to STDOUT.

### Panel

Panel or aggregate of LEDs. The description is defined in a configuration file that determines the width, height, bit depth, and other defining features.

### Output

Bus which the converted LED signals are pushed to such as SPI and UART. This includes specific configuration for signaling tricks to generate proper waveforms.

### Configuration

INI files used to configure the LED/panel generators, converters, and output buffers.

### Generation

Generates a frame which is the complete data set for the panel usually in RGB format.

### Conversion

Converts the frame into LED and bus specific data to be sent.

### Buffering

Utilize standard Linux facilities for input and output buffering to mitigate some data availability jitters.

## Pre-Requisites

* Bash
* PHP-CLI
* [libretech-wiring-tool](https://github.com/libre-computer-project/libretech-wiring-tool)

## LEDs Supported

* WS2812
* SK9822
* APA102

## License

GPL-2
