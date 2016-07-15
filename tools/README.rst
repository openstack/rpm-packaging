RPM Packaging for OpenStack internal tooling README
===================================================

This directory provides useful tooling for contributors to
the RPM Packaging project.


tools/run_renderspec.sh
+++++++++++++++++++++++

This tool can be used to generate usable spec files for all supported
RPM distributions from shipped templates. It will browse recursively
the directory passed in argument to find spec templates.
If no directory is given, it will search in current directory.

Usage::

  tools/run_renderspec.sh <path>


tools/run_speccleaner.sh
++++++++++++++++++++++++

This tool can be used to run spec-cleaner on generated spec files.
It will browse recursively the directory passed in argument and will
display as an unified diff, differences to our standards.
If no directory is given, it will search in current directory.

Usage::

  tools/run_speccleaner.sh <path>


