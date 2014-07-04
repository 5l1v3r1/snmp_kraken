#!/bin/bash
#
# Contact: Philipp Winter <phw@nymity.ch>
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org/>

if [ "$#" -lt 3 ]
then
	echo
	echo "Usage: $0 SMI_PATH OUTPUT_DIR IP_ADDRESS "
	echo
	echo -e "\tSMI_PATH must be a numeric SMI path, e.g., 1.3.6.1.2.1.1."
	echo -e "\tOUTPUT_DIR is where the data is written to."
	echo -e "\tIP_ADDRESS must contain an IP address."
	echo
	exit 1
fi

smi_path="$1"
output_dir="$2"
ip_addr="$3"

output_file="${output_dir}/${ip_addr}_snmp_smi:${smi_path}"

echo "[+] Now pulling SMI path ${smi_path} from address ${ip_addr}."

# Capture all SNMP traffic for later analysis.

tcpdump -i any -n "host ${ip_addr} and port 161" -w "${output_file}.pcap" &
pid=$!

snmpwalk -v 1 -t 5 -r 10 -c "public" "$ip_addr" "$smi_path" \
	> "${output_file}.txt" 2> "${output_file}_err.txt"

# Now terminate tcpdump(8).

if [ ! -z "$pid" ]
then
	kill "$pid"
	echo "[+] Sent SIGTERM to PID ${pid}."
fi

echo "[+] Done pulling SMI path from ${ip_addr}."
