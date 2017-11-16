#!/bin/bash
unit=$(echo $1 | cut -b ${#1})
string=$(echo $1 | cut -b 1-$((${#1}-1)))

case $unit in
  k) string=$string;;
  M) string=$(echo "scale=3; $string*1024" | bc);;
  G) string=$(echo "scale=3; $string*1024^2" | bc);;
  T) string=$(echo "scale=3; $string*1024^3" | bc);;
  P) string=$(echo "scale=3; $string*1024^4" | bc);;
  E) string=$(echo "scale=3; $string*1024^5" | bc);;
  Z) string=$(echo "scale=3; $string*1024^6" | bc);;
  *) echo "Please input one of ‘k M G T P E Z’ as unit. eg;40G"
  exit 1;;
esac

echo conversion of $1
answer=$string
printf "%20.3f kByte\n" $answer
answer=$(echo "scale=3; $string/1024" | bc)
printf "%20.3f MByte\n" $answer
answer=$(echo "scale=3; $string/1024/1024" | bc)
printf "%20.3f GByte\n" $answer
answer=$(echo "scale=3; $string/1024/1024/1024" | bc)
printf "%20.3f TByte\n" $answer
answer=$(echo "scale=3; $string/1024/1024/1024/1024" | bc)
printf "%20.3f PByte\n" $answer
answer=$(echo "scale=3; $string/1024/1024/1024/1024/1024" | bc)
printf "%20.3f EByte\n" $answer
answer=$(echo "scale=3; $string/1024/1024/1024/1024/1024/1024" | bc)
printf "%20.3f ZByte\n" $answer
