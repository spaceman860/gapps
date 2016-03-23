#!/bin/bash

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

# Pretty ascii art
echo "MY GAPPS";

# Define paths && variables
APP_DIRS="dynamic/FaceLock/arm/app/FaceLock dynamic/FaceLock/arm64/app/FaceLock dynamic/PrebuiltGmsCore/arm/priv-app/PrebuiltGmsCore dynamic/PrebuiltGmsCore/arm64/priv-app/PrebuiltGmsCore dynamic/SetupWizard/phone/priv-app/SetupWizard dynamic/SetupWizard/tablet/priv-app/SetupWizard dynamic/Velvet/arm/priv-app/Velvet dynamic/Velvet/arm64/priv-app/Velvet system/app/CalendarGoogle system/app/ChromeBookmarksSyncAdapter system/app/Drive system/app/GoogleCalendarSyncAdapter system/app/GoogleCamera system/app/GoogleContactsSyncAdapter system/app/GoogleHome system/app/GoogleInbox system/app/GoogleTTS system/app/Hangouts system/app/PlusOne system/app/TBO system/app/Wear system/app/YouTube system/priv-app/GoogleBackupTransport system/priv-app/GoogleFeedback system/priv-app/GoogleLoginService system/priv-app/GoogleOneTimeInitializer system/priv-app/GooglePartnerSetup system/priv-app/GoogleServicesFramework system/priv-app/HotwordEnrollment system/priv-app/Phonesky"
TOOLSDIR=$(realpath .)/tools
GAPPSDIR=$(realpath .)/files
FINALDIR=$(realpath .)/out
ZIPNAME1TITLE=My_Gapps
ZIPNAME1DATE=$(date +%-m-%-e-%-y)
ZIPNAME2TITLE=g
ZIPNAME2VERSION=6.XX
ZIPNAME1="$ZIPNAME1TITLE"_"$ZIPNAME1DATE".zip
ZIPNAME2="$ZIPNAME2TITLE"_"$ZIPNAME2VERSION".zip

dcapk() {
export PATH=$TOOLSDIR:$PATH
TARGETDIR=$(realpath .)
TARGETAPK=$TARGETDIR/$(basename "$TARGETDIR").apk
  unzip -q -o "$TARGETAPK" -d "$TARGETDIR" "lib/*"
  zip -q -d "$TARGETAPK" "lib/*"
  cd "$TARGETDIR"
  zip -q -r -D -Z store -b "$TARGETDIR" "$TARGETAPK" "lib/"
  rm -rf "${TARGETDIR:?}"/lib/
  mv -f "$TARGETAPK" "$TARGETAPK".orig
  zipalign -f -p 4 "$TARGETAPK".orig "$TARGETAPK"
  rm -rf "$TARGETAPK".orig
}

# Define beginning time
BEGIN=$(date +%s)

# Begin the magic
for dirs in $APP_DIRS; do
  cd "$GAPPSDIR/${dirs}";
  dcapk 1> /dev/null 2>&1;
done
cd "$GAPPSDIR"
zip -q -r -9 "$ZIPNAME1" ./*
mv -f "$ZIPNAME1" "$TOOLSDIR"
cd "$TOOLSDIR"
java -Xmx2048m -jar signapk.jar -w testkey.x509.pem testkey.pk8 "$ZIPNAME1" "$ZIPNAME1"
mv -f "$ZIPNAME1" "$FINALDIR"
cp -f "$FINALDIR"/"$ZIPNAME1" "$FINALDIR"/"$ZIPNAME2"

# Define ending time
END=$(date +%s)

echo " "
echo "All done creating GApps!"
echo "Total time elapsed: $(echo $(($END-$BEGIN)) | awk '{print int($1/60)"mins "int($1%60)"secs "}') ($(echo "$END - $BEGIN" | bc) seconds)"
echo "Completed GApp zips are located in the '$FINALDIR' directory"
