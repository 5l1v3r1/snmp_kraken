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

echo "[+] Writing all data to ${output_dir}/."

# Pull the entire MIB if no SMI path is given.  That might take a while.

if [ ! -z "$2" ]
then
	smi_path="$2"
else
	smi_path="."
fi

# Use xargs(1) as a process pool to parallelise execution.

cat "$address_file" | xargs -L 1 --max-procs 10 ./pull_data.sh \
	"$smi_path" "$output_dir"

echo "[+] Wrote all data to ${output_dir}/."
