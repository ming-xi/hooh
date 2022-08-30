#!/bin/bash
#./upload_fir_android.sh &
#./upload_fir_ios.sh &
if ! ./upload_fir_android.sh & then
    echo "build android error"
    exit 1
fi
if ! ./upload_fir_ios.sh & then
    echo "build ios error"
    exit 1
fi
wait
duration=$SECONDS
echo "completed in $((duration / 60))min $((duration % 60))s"