#!/bin/bash
./upload_fir_android.sh &
./upload_fir_ios.sh &
wait
duration=$SECONDS
echo "completed in $((duration / 60))min $((duration % 60))s"