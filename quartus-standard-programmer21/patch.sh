#!/bin/sh
#Get network address
net_card=$(ls /sys/class/net/ | grep -v lo | head -n 1)
net_address=$(cat "/sys/class/net/$net_card/address" | sed "s/://g")
contents=$(cat "$1/license.dat" | sed "s/XXXXXXXXXXXX/$net_address/g")
echo "$contents">"$1/license.dat"

#Get file offset
echo "file $1/quartus/linux64/libsys_cpt.so
info function l_pubkey_verify
q" > gdb_command.txt
offset=$(gdb --command=gdb_command.txt | grep -E "0x[0-f]+" | sed -r 's/0x0+| .*//g')
rm gdb_command.txt
#Write file
# shellcheck disable=SC2039
data=(0x31 0xc0 0xc3)
# shellcheck disable=SC2039
for i in {0..2} ; do
      data_offset=$(printf "%d" "0x$offset")
      data_offset=$((data_offset+i))
      ./ehex -name "$1/quartus/linux64/libsys_cpt.so" -data "${data[$i]}" --offset $data_offset
done

