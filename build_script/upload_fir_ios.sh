#!/bin/bash
if ! ./flutter_build_ipa_staging.sh; then
    echo "build ios error"
    exit 1
fi
cd ../app/ || exit
if ! fir publish build/ios/ipa/HOOH.ipa; then
    echo "publish ios error"
    exit 1
fi