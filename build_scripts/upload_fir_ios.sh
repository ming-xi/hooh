#!/bin/bash
./flutter_build_ipa_fir.sh
cd ../app/ || exit
fir publish build/ios/ipa/HOOH.ipa