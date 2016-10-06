#!/bin/sh
#ls -ARlS -D % | grep '^d\|^-' | sort -n -k 5 -r| awk 'BEGIN{i=1;dir_num=0;file_num=0;total=0;} $1 ~ /^-/ {if(i<=5){ print i":"$5,$7; i++;}file_num++;total=total+$5 } $1 ~ /^d/ {dir_num++;} END{print "DIR num:",dir_num;print "FILE num:",file_num;print "Total:",total;}'
ls -ARl | sort -n -k 5 -r| awk 'BEGIN{i=1;dir_num=0;file_num=0;total=0;} $1 ~ /^-/ {if(i<=5){ print i":"$5,$9; i++;}file_num++;total=total+$5 } $1 ~ /^d/ {dir_num++;} END{print "Dir num:",dir_num;print "File num:",file_num;print "Total:",total;}'
#awk 'BEGIN{"ls -ARl | sort -n -k 5 -r " |getline d;i=1;dir_num=0;file_num=0;total=0; } $1 ~ /^-/ {if(i<=5){ print i":"$5,$9; i++;}file_num++;total=total+$5 } $1 ~ /^d/ {dir_num++;} END{print "DIR num:",dir_num;print "FILE num:",file_num;print "Total:",total;}'
