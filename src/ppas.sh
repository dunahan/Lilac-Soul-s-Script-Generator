#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Linking /home/james/development/script generator/Lazarus/Scriptgen
OFS=$IFS
IFS="
"
/usr/bin/ld -b elf64-x86-64 -m elf_x86_64  --dynamic-linker=/lib64/ld-linux-x86-64.so.2    -L. -o "/home/james/development/script generator/Lazarus/Scriptgen" "/home/james/development/script generator/Lazarus/link.res"
if [ $? != 0 ]; then DoExitLink /home/james/development/script generator/Lazarus/Scriptgen; fi
IFS=$OFS
