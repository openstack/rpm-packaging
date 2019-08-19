#!/bin/bash

set -e

# 1st positional arg is the working dir
basedir=${1:-$PWD}
# 2nd positional arg is the find -name parameter
FIND_STR=${2:-*}

WORKSPACE=${WORKSPACE:-$basedir}
# tempfile to store the spec-cleaner diff for all specs
tmpdir=$(mktemp -d)
MAXPROC=4

echo "run spec-cleaner over specfiles from $WORKSPACE/logs/"

count=0
# TODO(toabctl): also run spec-cleaner with non-SUSE specs
# but the current problem is that the license check works for SUSE only
for spec in `find $WORKSPACE/logs/suse/ -name "*${FIND_STR}.spec" -type f -print` ; do
    echo "spec-cleaner checking $spec"
    # NOTE(toabctl):spec-cleaner can not ignore epochs currently
    sed -i '/^Epoch:.*/d' $spec
    # NOTE(jpena): spec-cleaner wants python2/python3 instead of
    # %{__python2}/%{__python3}
    # https://github.com/openSUSE/spec-cleaner/issues/173
    sed -i 's/%{__python2}/python2/g' $spec
    sed -i 's/%{__python3}/python3/g' $spec
    # NOTE(jaicaa): spec-cleaner does not like py2 and py3 single
    # line BuildRequires, pick py2:
    # BuildRequires: python-X python3-X -> BuildRequires: python-X
    # BuildRequires: python3-X python-X -> BuildRequires: python-X
    # BuildRequires: python2-X python3-X -> BuildRequires: python2-X
    # BuildRequires: python3-X python2-X -> BuildRequires: python2-X
    sed -i 's/^\(BuildRequires:.*\)python-\(.*\b\).*python3-\2$/\1python-\2/g' $spec
    sed -i 's/^\(BuildRequires:.*\)python3-\(.*\b\).*python-\2$/\1python-\2/g' $spec
    sed -i 's/^\(BuildRequires:.*\)python2-\(.*\b\).*python3-\2$/\1python2-\2/g' $spec
    sed -i 's/^\(BuildRequires:.*\)python3-\(.*\b\).*python2-\2$/\1python2-\2/g' $spec
    spec-cleaner -m -d --no-copyright --diff-prog "diff -uw" \
                 $spec > $tmpdir/`basename ${spec}`.cleaner.diff &
    let count+=1
    [[ count -eq $MAXPROC ]] && wait && count=0
done

wait

# check if some diffs are available
failed=0
for specdiff in $tmpdir/*; do
    if [ -s "$specdiff" ]; then
        echo "##### `basename ${specdiff}` ##### "
        cat $specdiff
        failed=1
    fi
done

exit $failed
