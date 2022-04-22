#!/bin/bash
cd ..
modules=('common' 'app')
for module in "${modules[@]}" ; do
    echo "dir = $module"
    cd "$module" || exit
    flutter pub run build_runner build --delete-conflicting-outputs
    cd ..
done