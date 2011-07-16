#!/bin/bash

unalias ls 2> /dev/null

# Cleans up flat files containing migration-specific data. Use before commiting changes.

for each in `cat ignore.txt`; do cat /dev/null > $each;done

echo "Migration data cleaned up."
