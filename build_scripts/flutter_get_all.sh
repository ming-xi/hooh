#!/bin/bash
cd ..
modules=('common' 'app')
for module in "${modules[@]}" ; do
    echo "dir = $module"
    cd "$module" || exit
    flutter pub get
    cd ..
done