#!/bin/bash

set -eux

basedir=${1:-$PWD}
specdir=${basedir}/openstack/

WORKSPACE=${WORKSPACE:-$basedir}
OUTPUTDIR=$WORKSPACE/logs/
specstyles="suse fedora"
MAXPROC=4

mkdir -p $OUTPUTDIR

# clean up output dir
for specstyle in $specstyles; do
    rm -f $OUTPUTDIR/*.${specstyle}
done

count=0
echo "run renderspec over specfiles from ${specdir}"
for spec in ${specdir}/**/*.spec.j2; do
    for specstyle in $specstyles; do
        echo "run ${spec} for ${specstyle}"
        renderspec --spec-style ${specstyle} ${spec} \
                   -o $WORKSPACE/logs/${spec##*/}.${specstyle} &
        let count+=1
        [[ count -eq $MAXPROC ]] && wait && count=0
    done
done

wait
