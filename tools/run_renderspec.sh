#!/bin/bash

set -eux

basedir=${1:-$PWD}
specdir=${basedir}/openstack/

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
echo "run renderspec over specfiles from ${specdir}"
for specstyle in $specstyles; do
    find ${specdir} -name '*.spec.j2' -type f -print0 | \
        xargs -n 1 -0 -P 0 -I __SPEC__ bash -c "
            set -e
            skip='--skip-pyversion py3'
            if grep -q '%package -n python3-' __SPEC__; then
                skip=""
            fi
            pkg_name=\$(pymod2pkg --dist $specstyle \$(basename __SPEC__ .spec.j2))
            renderspec --spec-style $specstyle __SPEC__ \
                \$skip -o $WORKSPACE/logs/$specstyle/\$pkg_name.spec"
done
