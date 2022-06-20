#!/bin/bash
cd ../app/ || exit
flutter build ipa --export-options-plist ios/export-options-fir.plist --release -t lib/main_staging.dart