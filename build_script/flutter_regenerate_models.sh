#!/bin/bash
if ! ./flutter_get_all.sh; then
    echo "flutter get error"
    exit 1
fi
cd ..
modules=('common' 'app' 'crm')
for module in "${modules[@]}" ; do
    echo "dir = $module"
    cd "$module" || exit
    flutter pub run build_runner build --delete-conflicting-outputs
    cd ..
done