#!/sbin/sh

#    This file contains parts from the scripts taken from the Open GApps Project by mfonville.
#
#    The Open GApps scripts are free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    These scripts are distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

# Functions & variables
rom_build_prop=/system/build.prop

# get file descriptor for output
OUTFD=$(ps | grep -v grep | grep -oE "update-binary(.*)" | cut -d " " -f 3)

ui_print() {
    if [ -n "$OUTFD" ]; then
        echo "ui_print ${1} " 1>&$OUTFD;
        echo "ui_print " 1>&$OUTFD;
    else
        echo "${1}";
    fi;
}

file_getprop() {
    grep "^$2" "$1" | cut -d= -f2;
}

if [ -e $rom_build_prop ]
then
    rom_build_name=$(file_getprop $rom_build_prop ro.build.display.id)
    ui_print "ROM build: $rom_build_name"

    # prevent installation of incorrect gapps version
    rom_version_required=6.0
    rom_version_installed=$(file_getprop $rom_build_prop ro.build.version.release)
    ui_print "ROM version required: $rom_version_required"
    ui_print "ROM version installed: $rom_version_installed"
    if [ -z "${rom_version_installed##*$rom_version_required*}" ]
    then
        ui_print "ROM and GApps versions match...proceeding";
    else
        ui_print "ROM and GApps versions don't match...aborting";
        exit 1
    fi

    # prevent installation of gapps on wrong architecture
    # (this package supports armeabi, armeabi-v7a, and arm64-v8.
    #  so, as long as the retrieved architecture from build.prop contains
    #  "arm" then the device is supported.)
    architecture_required=arm
    architecture_installed="$(file_getprop $rom_build_prop "ro.product.cpu.abilist=")"
    # If the recommended field is empty, fall back to the deprecated one
    if [ -z "$architecture_installed" ]; then
      architecture_installed="$(file_getprop $rom_build_prop "ro.product.cpu.abi=")"
    fi
    ui_print "Architecture required: $architecture_required"
    ui_print "Current cpu architecture(s) supported: $architecture_installed"
    if ! (echo "$architecture_installed" | grep -qi "$architecture_required"); then
        exit 1
    else
        ui_print "Architecture check passed...proceeding";
    fi
fi

exit 0
