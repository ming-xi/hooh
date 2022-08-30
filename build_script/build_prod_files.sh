#!/bin/bash
if ! ./flutter_build_apk_prod.sh & then
    echo "build android error"
    exit 1
fi
if ! ./flutter_build_ipa_prod.sh & then
    echo "build ios error"
    exit 1
fi
wait
duration=$SECONDS
echo "completed in $((duration / 60))min $((duration % 60))s"
#aapt dump badging ../app/build/app/outputs/flutter-apk/app-release.apk |grep versionCode
open "../app/build/app/outputs/flutter-apk/"
open "../app/build/ios/ipa/"
