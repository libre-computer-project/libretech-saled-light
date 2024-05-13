#!/bin/bash
set -e

if [ -z "$1" ]; then
	echo "$0 $SALED_CONFIG" >&2
	exit 1
fi

if [ ! -f "$1" ]; then
	echo "$1 is not a valid config file." >&2
	exit 1
fi

SALED_CONFIG="$1"
. "$SALED_CONFIG"

cd $(dirname $(readlink -f "${BASH_SOURCE[0]}"))

. led/$SALED_PANEL_LED.ini

if [ -z "$SALED_SPI_DEV" ]; then
	echo "SALED_SPI_DEV is not set." >&2
	exit 1
fi

if [ -z "$SALED_SPI_FREQ" ]; then
	echo "SALED_SPI_FREQ is not set." >&2
	exit 1
fi

SPI_DEV=/dev/spidev${SALED_SPI_DEV}.0

if [ ! -e "$SPI_DEV" ]; then
	echo "SPI DEV $SPI_DEV does not exist." >&2
	exit 1
fi

if [ ! -w "$SPI_DEV" ]; then
	echo "SPI DEV $SPI_DEV not writable by current user." >&2
	exit 1
fi

if ! which php > /dev/null; then
	echo "Please run setup.sh or install php-cli." >&2
	exit 1
fi

spi-config -d "$SPI_DEV" -s "$SALED_SPI_FREQ" -m "$SALED_LED_SPI_MODE" -b $SALED_LED_SPI_TRANSFER_BITS -w &
trap "kill $!" EXIT

if [ ! -z "$SALED_PANEL_BUFFER_INPUT_FRAMES" ]; then
	SALED_BUF_IN="-i$((((SALED_PANEL_WIDTH * SALED_PANEL_HEIGHT) * SALED_LED_PIXEL_BYTES + SALED_LED_FRAME_INIT_BYTES) * $SALED_PANEL_BUFFER_INPUT_FRAMES))"
fi

if [ ! -z "$SALED_PANEL_BUFFER_OUTPUT_FRAMES" ]; then
	SALED_BUF_OUT="-o$((((SALED_PANEL_WIDTH * SALED_PANEL_HEIGHT) * SALED_LED_PIXEL_BYTES + SALED_LED_FRAME_INIT_BYTES) * $SALED_PANEL_BUFFER_OUTPUT_FRAMES))"
fi

./gen/"$SALED_GEN_ALGO" "$SALED_CONFIG"  | stdbuf $SALED_BUF_IN $SALED_BUF_OUT ./led/$SALED_PANEL_LED "$SALED_CONFIG" > "$SPI_DEV"
