#!/bin/sh

    j=0;
    initlan=$( cat /sys/class/leds/gl-ar150\:green\:lan/brightness)
    initwan=$( cat /sys/class/leds/gl-ar150\:green\:wan/brightness)

    for i in $( seq 1 10 ); do
        echo "$j"> /sys/class/leds/gl-ar150\:green\:lan/brightness
        echo "$j"> /sys/class/leds/gl-ar150\:green\:wan/brightness
        sleep 1;
        if [ "$j" -eq "0" ]; then
            j=1;
        else
            j=0;
        fi
    done

    echo "$initlan"> /sys/class/leds/gl-ar150\:green\:lan/brightness
    echo "$initwan"> /sys/class/leds/gl-ar150\:green\:wan/brightness 
