#!/bin/sh

help()
{
    echo 'usage: makecart.sh code background output'
}

if [ "$1" = "-h" -o "$1" = "--help" ] ; then
    help
    exit
fi

if [ -z "$1" ] ; then
    echo 'makecart: missing code operand'
    help
    exit 1
fi

if [ -z "$2" ] ; then
    echo 'makecart: missing background operand'
	help
    exit 1
fi

if [ -z "$3" ] ; then
    echo 'makecart: missing output operand'
	help
    exit 1
fi

code=$1
background=$2
output=$3

temp_ppm="$(mktemp --suffix=.ppm)"
temp_code="$(mktemp --suffix=.png)"

lua click42ppm.lua ${code} > ${temp_ppm}
magick ${temp_ppm} -transparent "rgb(31,31,31)" ${temp_code}
convert ${background} ${temp_code} -gravity east -flatten ${output}

rm ${temp_ppm}
rm ${temp_code}
