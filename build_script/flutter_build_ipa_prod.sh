#!/bin/bash
cd ../app/ || exit
#flutter build ipa --export-options-plist ios/export-options-fir.plist --release -t lib/main_staging.dart
flutter build ipa  --export-options-plist ios/export-options-prod.plist --release
open /Users/xumingke/Work/Flutter/hooh/app/build/ios/ipa
