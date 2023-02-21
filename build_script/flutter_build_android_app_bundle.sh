#!/bin/bash
cd ../app/ || exit
flutter build appbundle
open "../app/build/app/outputs/bundle/release/"