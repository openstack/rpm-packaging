#!/bin/bash

set -eux

# 1st positional arg is the working dir
basedir=${1:-$PWD}
# 2nd positional arg is the find -name parameter
FIND_STR=${2:-*}

specdirs="${basedir}/openstack/ ${basedir}/airship/ ${basedir}/x/"

WORKSPACE=${WORKSPACE:-$basedir}
OUTPUTDIR=$WORKSPACE/logs/
specstyles="suse fedora"
MAXPROC=4

# clean up output dir
for specstyle in $specstyles; do
    mkdir -p $OUTPUTDIR/${specstyle}/
    rm -rf $OUTPUTDIR/${specstyle}/*
done

count=0
echo "run renderspec over specfiles from ${specdirs}"
for specstyle in $specstyles; do
    for specdir in $specdirs; do
         find ${specdir} -name "${FIND_STR}.spec.j2" -type f -print0 | \
             xargs -n 1 -0 -P 0 -I __SPEC__ bash -c "
                 set -e
                 pkg_name=\$(pymod2pkg --dist $specstyle \$(basename __SPEC__ .spec.j2))
                 renderspec --spec-style $specstyle __SPEC__ \
                     -o $WORKSPACE/logs/$specstyle/\$pkg_name.spec"
     done
done
