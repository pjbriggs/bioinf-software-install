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

To install library packages under a non-root location (e.g. `SITE_PYTHON`), use:

    install_python_package.sh ${OPT}/python/2.7.2/bin/python numpy-1.8.0.tar.gz ${SITE_PYTHON}

To make the library packages available:

    export PATH=${SITE_PYTHON}/bin:$PATH
    export PYTHONPATH=${SITE_PYTHON}/lib/python2.7/site-packages:$PYTHONPATH

To install applications under their own version-specific locations, use:

    install_python_app.sh ${OPT}/python/2.7.2/bin/python HTSeq-0.5.4p5.tar.gz ${OPT}

You will need to add the `bin` and `lib/python-2.7/site-packages` directories
to `PATH` and `PYTHONPATH` respectively.

Perl
----

TBA

R and Bioconductor
------------------

Use:

    build_R.sh R-3.0.2.tar.gz $OPT

to build and install to `${OPT}/R/3.0.2`

To install packages under a non-root location (e.g. `SITE_R`) directly from
CRAN, use:

    install_R_package.sh ${OPT}/R/3.0.2/bin/R igraph ${SITE_R}

Alternatively the same command can be used to install from a previously
downloaded archive file:

    install_R_package.sh ${OPT}/R/3.0.2/bin/R zinba_2.02.03.tar.gz ${SITE_R}

To make the packages available:

    export R_LIBS=${SITE_R}:$R_LIBS

(NB R also supports `R_LIBS_USER` and `R_LIBS_SITE` variables.)

To install Bioconductor packages use:

    install_bioc_package.sh ${OPT}/R/3.0.2/bin/R SRAdb ${SITE_R}

### Comments ###

This is a work in progress.

Note that there is no error checking so installations might fail and
we wouldn't know.

To check if a package is available do:

    library("<package>")

To update a CRAN package do

    update.packages("<package>")

Information on managing and upgrading Bioconductor packages can be found
at [http://www.bioconductor.org/install]

The Bioconductor installer is quite inefficient as it updates biocLite.R
each time, and can only be run for one package at a time.
