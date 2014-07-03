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

if [ "$#" -lt 1 ]
then
	echo
	echo "Usage: $0 ADDRESS_FILE [SMI_PATH]"
	echo
	echo -e "\tADDRESS_FILE must contain line-separated IP addresses."
	echo -e "\tSMI_PATH must be a numeric SMI path, e.g., 1.3.6.1.2.1.1."
	echo
	exit 1
fi

address_file="$1"
output_dir="$(mktemp -d '/tmp/kraken-XXXXXX')"

# Pull the entire MIB if no SMI path is given.  That might take a while.

if [ ! -z "$2" ]
then
	smi_path="$2"
else
	smi_path="."
fi

while read dest
do

	output_file="${output_dir}/${dest}_snmp_smi:${smi_path}"

	echo "[+] Now pulling SMI path ${smi_path} from ${dest}."

	# Capture all SNMP traffic for later analysis.

	tcpdump -i any -n "host ${dest} and port 161" -w "${output_file}.pcap" &
	pid=$!

	time snmpwalk -v 1 -t 5 -r 10 -c "public" "$dest" "$smi_path" > \
		"${output_file}.txt" 2> "${output_file}_err.txt"

	# Now terminate tcpdump(8).

	if [ ! -z "$pid" ]
	then
		kill "$pid"
		echo "[+] Sent SIGTERM to PID ${pid}."
	fi

done < "$address_file"

echo "[+] Wrote all data to ${output_dir}/."
