#!/bin/bash

set -e

basedir=${1:-$PWD}

WORKSPACE=${WORKSPACE:-$basedir}

echo "run checks over specfiles from $WORKSPACE/logs/"

failed=0
for spec in $WORKSPACE/logs/suse/*.spec ; do
    egrep -q '^Source:' $spec && {
        echo "$spec should not have Source: lines. Please use Source0: instead."
        failed=1
    }
    egrep -q '^%setup' $spec && {
        echo "$spec should not use '%setup'. Please use '%autosetup' instead."
        failed=1
    }

    pushd $(dirname $spec) >/dev/null
    rpmspec -q --qf "%{VERSION}\n" $(basename $spec) >/dev/null || {
            echo "$spec does not parse properly. Please check your syntax."
            failed=1
        }
    popd > /dev/null
done

exit $failed
