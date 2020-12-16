#!/bin/bash
# MIT License. See LICENSE file.

[[ $# -lt 1 ]] && { echo "Usage: ./ci-build.sh <vm1> <vm2>..."; exit 1; }

for arg in "$@"
do
	METADATA="cloud-init/${arg}_meta-data"
	USERDATA="cloud-init/${arg}_user-data"
	ISO="cloud-init/${arg}_cidata.iso"

	# Check if files exist in cloud-init directory
	( [[ ! -f ${METADATA} ]] || [[ ! -f ${USERDATA} ]] ) && { echo "Metadata files not found for ${arg}, skipping."; continue; }

	echo "Building image to ${ISO}..."

	# Copy metadata files to a temp directory
	mkdir -p /tmp/build
	cp ${METADATA} /tmp/build/meta-data
	cp ${USERDATA} /tmp/build/user-data

	# Make ISO
	xorrisofs -v -o ${ISO} -V cidata -J -r /tmp/build/ 2>cloud-init/${arg}-build.log

	# Check ISO
	FILESIZE=$(stat -c %s ${ISO} 2>/dev/null)
	if [[ ${FILESIZE} -gt 0 ]]; then
		printf '%s (%d bytes) ... done!\n' ${ISO} ${FILESIZE}
	else
		printf 'Something went wrong while trying to make %s\n' ${ISO}
	fi

	# Cleanup
	rm -fr /tmp/build
done