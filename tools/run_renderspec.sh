#!/bin/bash

set -eux

basedir=$1
specdir=${basedir}/openstack/

WORKSPACE=${WORKSPACE:-$basedir}

echo "run renderspec over specfiles from ${specdir}"
for spec in ${specdir}/**/*.spec.j2; do
    mkdir -p $WORKSPACE/logs/
    for specstyle in "suse" "fedora"; do
        echo "run ${spec} for ${specstyle}"
        renderspec --spec-style ${specstyle} ${spec} \
                   -o $WORKSPACE/logs/`basename ${spec}`.${specstyle}
    done
done
