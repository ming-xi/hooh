#!/bin/bash
if ! ./flutter_build_apk_staging.sh; then
    echo "build android error"
    exit 1
fi
cd ../app/ || exit
if ! fir publish build/app/outputs/apk/release/app-release.apk; then
    echo "publish android error"
    exit 1
fi