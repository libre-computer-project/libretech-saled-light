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

if [ -z "$SALED_DEV_BUS" ]; then
	echo "SALED_DEV_BUS is not set." >&2
	exit 1
fi

if [ -z "$SALED_DEV" ]; then
	echo "SALED_DEV is not set." >&2
	exit 1
fi

if [ -z "$SALED_DEV_BAUD" ]; then
	echo "SALED_DEV_BAUD is not set." >&2
	exit 1
fi

case "$SALED_DEV_BUS" in
	"spi")
		SALED_DEV_PATH=/dev/spidev${SALED_DEV}.0
		SALED_DEV_CMD=spi-config
		SALED_DEV_CMD_DEV="-d "
		SALED_DEV_CMD_BAUD="-s "
		SALED_DEV_CMD_MODE="-m "
		SALED_DEV_CMD_CHUNK="-b "
		SALED_DEV_CMD_EXTRA="-w "
		if ! which $SALED_DEV_CMD > /dev/null; then
			echo "Please run setup.sh or install spi-tools." >&2
			exit 1
		fi
		;;
	"uart")
		SALED_DEV_PATH=/dev/tty${SALED_DEV}
		SALED_DEV_CMD=stty
		SALED_DEV_CMD_DEV="-F "
		SALED_DEV_CMD_BAUD=""
		SALED_DEV_CMD_MODE=""
		SALED_DEV_CMD_CHUNK="cs"
		SALED_DEV_CMD_EXTRA=""
		;;
	*)
		echo "SALED_DEV_BUS $SALED_DEV_BUS is not supported." >&2
		exit 1
		;;
esac

if [ ! -e "$SALED_DEV_PATH" ]; then
	echo "SALED_DEV_PATH $SALED_DEV_PATH does not exist." >&2
	exit 1
fi

if [ ! -w "$SALED_DEV_PATH" ]; then
	echo "SALED_DEV_PATH $SALED_DEV_PATH not writable by current user." >&2
	exit 1
fi

if ! which php > /dev/null; then
	echo "Please run setup.sh or install php-cli." >&2
	exit 1
fi

$SALED_DEV_CMD $SALED_DEV_CMD_DEV$SALED_DEV_PATH $SALED_DEV_CMD_BAUD$SALED_DEV_BAUD $SALED_DEV_CMD_MODE$SALED_DEV_MODE $SALED_DEV_CMD_CHUNK$SALED_DEV_CHUNK $SALED_DEV_CMD_EXTRA &
#spi-config -d "$SPI_DEV" -s "$SALED_SPI_FREQ" -m "$SALED_LED_SPI_MODE" -b $SALED_LED_SPI_TRANSFER_BITS -w &
trap "if ps -p $! > /dev/null; then kill $!; fi" EXIT

SALED_FRAME_SIZE=$((SALED_PANEL_WIDTH * SALED_PANEL_HEIGHT * SALED_LED_PIXEL_BYTES + SALED_LED_FRAME_INIT_BYTES))

if [ ! -z "$SALED_PANEL_BUFFER_INPUT_FRAMES" ]; then
	SALED_BUF_IN="-i$((SALED_FRAME_SIZE * $SALED_PANEL_BUFFER_INPUT_FRAMES))"
fi

if [ ! -z "$SALED_PANEL_BUFFER_OUTPUT_FRAMES" ]; then
	SALED_BUF_OUT="-o$(($SALED_FRAME_SIZE * $SALED_PANEL_BUFFER_OUTPUT_FRAMES))"
fi

./gen/"$SALED_GEN_ALGO" "$SALED_CONFIG"  | stdbuf $SALED_BUF_IN $SALED_BUF_OUT ./led/$SALED_PANEL_LED "$SALED_CONFIG" > "$SALED_DEV_PATH"
