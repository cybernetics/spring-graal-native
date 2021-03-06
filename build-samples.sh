#!/usr/bin/env bash

echo "Graal: `native-image --version`" > samples-summary.csv
echo "Date,Sample,Build Time (s),Build Mem (GB),RSS Mem (M),Image Size (M),Startup Time (s),JVM Uptime (s)" >> samples-summary.csv
for d in $(find spring-graal-native-samples -maxdepth 2 -type d)
do
  if [[ -f "$d/build.sh" ]]; then
    (cd "$d" && ./build.sh)
    if [ -f "$d/target/native-image/summary.csv" ]; then
      cat $d/target/native-image/summary.csv >> samples-summary.csv
    else
      echo `date +%Y%m%d-%H%M`,`basename $d`,ERROR,-,,,, >> samples-summary.csv
    fi
  fi
done

head -1 samples-summary.csv
if ! [ -x "$(command -v tty-table)" ]; then
  tail -n +2 samples-summary.csv | perl -pe 's/((?<=,)|(?<=^)),/ ,/g;'  | column -t -s,
else
  tail -n +2 samples-summary.csv | tty-table
fi
