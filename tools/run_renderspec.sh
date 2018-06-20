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

py3onlypackages=("openstack-keystone")

count=0
echo "run renderspec over specfiles from ${specdir}"
for specstyle in $specstyles; do
    for spec in ${specdir}/**/*.spec.j2; do
        echo "run ${spec} for ${specstyle}"
        pkg_name=$(pymod2pkg --dist $specstyle $(basename $spec .spec.j2))
        if [[ ! " ${py3onlypackages[@]} " =~ " ${pkg_name} " ]];then
          skip="--skip-pyversion py3"
        else
          skip=""
        fi
        renderspec --spec-style ${specstyle} ${spec} \
                   --requirements $basedir/global-requirements.txt ${skip} \
                   -o $WORKSPACE/logs/${specstyle}/$pkg_name.spec &
        let count+=1
        [[ count -eq $MAXPROC ]] && wait && count=0
    done
done

wait
