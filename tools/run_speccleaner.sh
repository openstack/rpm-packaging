#!/bin/bash

set -e

basedir=$1

WORKSPACE=${WORKSPACE:-$basedir}
# tempfile to store the spec-cleaner diff for all specs
tmpdir=$(mktemp -d)

echo "run spec-cleaner over specfiles from $WORKSPACE/logs/"

# TODO(toabctl): also run spec-cleaner with non-SUSE specs
# but the current problem is that the license check works for SUSE only
for spec in $WORKSPACE/logs/*.suse ; do
    # NOTE(toabctl):spec-cleaner can not ignore epochs currently
    sed -i '/^Epoch:.*/d' $spec
    spec-cleaner -m -d --no-copyright --diff-prog "diff -uw" \
                 $spec > $tmpdir/`basename ${spec}`.cleaner.diff
done

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
