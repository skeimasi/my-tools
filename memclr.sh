#!/bin/bash

echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'
# swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'
