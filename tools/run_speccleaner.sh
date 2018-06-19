#!/bin/bash

set -e

basedir=${1:-$PWD}

WORKSPACE=${WORKSPACE:-$basedir}
# tempfile to store the spec-cleaner diff for all specs
tmpdir=$(mktemp -d)
MAXPROC=4

echo "run spec-cleaner over specfiles from $WORKSPACE/logs/"

count=0
# TODO(toabctl): also run spec-cleaner with non-SUSE specs
# but the current problem is that the license check works for SUSE only
for spec in $WORKSPACE/logs/suse/*.spec ; do
    # NOTE(toabctl):spec-cleaner can not ignore epochs currently
    sed -i '/^Epoch:.*/d' $spec
    # NOTE(jpena): spec-cleaner wants python2/python3 instead of
    # %{__python2}/%{__python3}
    # https://github.com/openSUSE/spec-cleaner/issues/173
    sed -i 's/%{__python2}/python2/g' $spec
    sed -i 's/%{__python3}/python3/g' $spec
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
