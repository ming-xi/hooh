#!/bin/bash
cd ../web/ || exit
flutter build web --release --web-renderer html --base-href "/site/" -t lib/main.dart
#flutter build web --release --tree-shake-icons --web-renderer html --base-href "/landing/web/" -t lib/main.dart