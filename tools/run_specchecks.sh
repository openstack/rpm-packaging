#!/bin/bash

set -e

basedir=${1:-$PWD}

WORKSPACE=${WORKSPACE:-$basedir}

echo "run checks over specfiles from $WORKSPACE/logs/"

failed=0
for spec in $WORKSPACE/logs/*.suse ; do
    egrep -q '^Source:' $spec && {
        echo "$spec should not have Source: lines. Please use Source0: instead."
        failed=1
    }
done

exit $failed
