Scripts to help with building and deploying bioinformatics software
===================================================================

Various random scripts to help with building and deploying software used for
bioinformatics (python, perl, R).

Overview
--------

Where possible we prefer to install multiple versions of "major" packages
using the scheme:

    ${OPT}/<PACKAGE>/<VERSION>

e.g.

    ${OPT}/R/3.0.2

where `OPT` is a stand-in for the top level installation location.

For specific Python, perl or R libraries we prefer to install to
site-specific locations

    ${OPT_LIBS}/site-python
    ${OPT_LIBS}/site-perl
    ${OPT_LIBS}/R

Python
------

Use:

    build_python.sh Python-2.7.2.tar.gz $OPT

to build and install to `${OPT}/python/2.7.2`

To install library packages into a non-root location, use:

    install_python_package ${OPT}/python/2.7.2/bin/python numpy-1.8.0.tar.gz ${SITE_PYTHON}

To make the packages available:

    export PATH=${SITE_PYTHON}/bin:$PATH
    export PYTHONPATH=${SITE_PYTHON}/lib/python2.7/site-packages:$PYTHONPATH

Perl
----

TBA

R
-

TBA