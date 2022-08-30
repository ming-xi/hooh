#!/bin/bash
cd ..
modules=('common' 'app'  'crm')
for module in "${modules[@]}" ; do
    echo "dir = $module"
    cd "$module" || exit
    flutter pub run build_runner build
    cd ..
done