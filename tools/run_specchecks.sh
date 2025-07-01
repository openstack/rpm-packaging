#!/bin/bash

set -e

# 1st positional arg is the working dir
basedir=${1:-$PWD}
# 2nd positional arg is the find -name parameter
FIND_STR=${2:-*}

WORKSPACE=${WORKSPACE:-$basedir}

echo "run checks over specfiles from $WORKSPACE/logs/"

thome=$(mktemp -d)
cat openstack/openstack-macros/macros.openstack-singlespec > $thome/.rpmmacros

failed=0
for spec in `find $WORKSPACE/logs/suse/ -name "*${FIND_STR}.spec" -type f -print` ; do
    echo "Checking $spec"
    grep -E -q '^Source:' $spec && {
        echo "$spec should not have Source: lines. Please use Source0: instead."
        failed=1
    }
    grep -E -q '^%setup' $spec && {
        echo "$spec should not use '%setup'. Please use '%autosetup' instead."
        failed=1
    }

    pushd $(dirname $spec) >/dev/null
    HOME=$thome rpmspec -q --qf "%{VERSION}\n" $(basename $spec) >/dev/null || {
            echo "$spec does not parse properly. Please check your syntax."
            failed=1
        }
    popd > /dev/null
done

rm -rf $thome

exit $failed
