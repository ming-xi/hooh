#!/bin/bash
./flutter_build_single_apk.sh
cd ../app/ || exit
fir publish build/app/outputs/apk/release/app-release.apk