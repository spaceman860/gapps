#!/sbin/sh

# Functions & variables
file_getprop() {
    grep "^$2" "$1" | cut -d= -f2;
}

rom_build_prop=/system/build.prop
device_architecture="$(file_getprop $rom_build_prop "ro.product.cpu.abilist=")"
# If the recommended field is empty, fall back to the deprecated one
if [ -z "$device_architecture" ]; then
  device_architecture="$(file_getprop $rom_build_prop "ro.product.cpu.abi=")"
fi
is_tablet="$(grep ro.build.characteristics $rom_build_prop | grep tablet)"
lcd="$(grep ro.sf.lcd_density $rom_build_prop | cut -d "=" -f 2)"

# FaceLock
if (echo "$device_architecture" | grep -i "armeabi" | grep -qiv "arm64"); then
  cp -rf /tmp/FaceLock/arm/* /system
elif (echo "$device_architecture" | grep -qi "arm64"); then
  cp -rf /tmp/FaceLock/arm64/* /system
fi

# Libs
if (echo "$device_architecture" | grep -i "armeabi" | grep -qiv "arm64"); then
  cp -rf /tmp/Libs/system/lib/* /system/lib
  cp -rf /tmp/Libs/system/vendor/lib/* /system/vendor/lib
elif (echo "$device_architecture" | grep -qi "arm64"); then
  cp -rf /tmp/Libs/system/lib64/* /system/lib64
  cp -rf /tmp/Libs/system/vendor/lib/* /system/vendor/lib
  cp -rf /tmp/Libs/system/vendor/lib64/* /system/vendor/lib64
fi

# PrebuiltGmsCore
if [ $lcd == 240 ]; then
  cp -rf /tmp/PrebuiltGmsCore/434/* /system
elif [ $lcd == 320 ]; then
  cp -rf /tmp/PrebuiltGmsCore/436/* /system
elif [ $lcd == 480 ]; then
  cp -rf /tmp/PrebuiltGmsCore/438/* /system
else
  cp -rf /tmp/PrebuiltGmsCore/430/* /system
fi 

if (echo "$device_architecture" | grep -qi "arm64"); then
  rm -rf /system/priv-app/PrebuiltGmsCore
    if [ $lcd == 320 ]; then
      cp -rf /tmp/PrebuiltGmsCore/446/* /system
    else
      cp -rf /tmp/PrebuiltGmsCore/440/* /system
    fi
fi

# SetupWizard
if [ -n "$is_tablet" ]; then
  cp -rf /tmp/SetupWizard/tablet/* /system
else
  cp -rf /tmp/SetupWizard/phone/* /system
fi

# Velvet
if (echo "$device_architecture" | grep -i "armeabi" | grep -qiv "arm64"); then
  cp -rf /tmp/Velvet/arm/* /system
elif (echo "$device_architecture" | grep -qi "arm64"); then
  cp -rf /tmp/Velvet/arm64/* /system
fi

# Make required symbolic links
if (echo "$device_architecture" | grep -i "armeabi" | grep -qiv "arm64"); then
  mkdir -p /system/app/FaceLock/lib/arm
  mkdir -p /system/app/LatinIME/lib/arm
  ln -sfn /system/lib/libfacelock_jni.so /system/app/FaceLock/lib/arm/libfacelock_jni.so
  ln -sfn /system/lib/libjni_latinime.so /system/app/LatinIME/lib/arm/libjni_latinime.so
  ln -sfn /system/lib/libjni_latinimegoogle.so /system/app/LatinIME/lib/arm/libjni_latinimegoogle.so
elif (echo "$device_architecture" | grep -qi "arm64"); then
  mkdir -p /system/app/FaceLock/lib/arm64
  mkdir -p /system/app/LatinIME/lib/arm64
  ln -sfn /system/lib64/libfacelock_jni.so /system/app/FaceLock/lib/arm64/libfacelock_jni.so
  ln -sfn /system/lib64/libjni_latinime.so /system/app/LatinIME/lib/arm64/libjni_latinime.so
  ln -sfn /system/lib64/libjni_latinimegoogle.so /system/app/LatinIME/lib/arm64/libjni_latinimegoogle.so
fi

exit 0
