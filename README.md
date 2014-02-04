Scripts to help with building and deploying bioinformatics software
===================================================================

Various random scripts to help with building and deploying software used
for bioinformatics (python, perl, R).

The intention is to provide support for "managed installations" of
different versions of Python, Perl and R which are completely
independent of those provided via the system's package manager (e.g.
yum).

Overview
--------

Where possible we prefer to install multiple versions of "major" packages
using the scheme:

    ${OPT}/<PACKAGE>/<VERSION>

e.g.

    ${OPT}/R/3.0.2

where `OPT` is a stand-in for the top level installation location.

For specific Python, perl or R libraries we prefer to install to
site-specific locations, e.g.

    ${OPT_LIBS}/site-python
    ${OPT_LIBS}/site-perl
    ${OPT_LIBS}/R

within which there is also a level of versioning, e.g.

    ${SITE_R}/3.0


Python
------

Use:

    build_python.sh Python-2.7.2.tar.gz $OPT

to build and install to `${OPT}/python/2.7.2`

To install library packages under a non-root location (e.g. `SITE_PYTHON`), use:

    install_python_package.sh ${OPT}/python/2.7.2/bin/python numpy-1.8.0.tar.gz ${SITE_PYTHON}

To make the library packages available:

    export PATH=${SITE_PYTHON}/2.7/bin:$PATH
    export PYTHONPATH=${SITE_PYTHON}/2.7/lib/python2.7/site-packages:$PYTHONPATH

To install applications under their own version-specific locations, use:

    install_python_app.sh ${OPT}/python/2.7.2/bin/python HTSeq-0.5.4p5.tar.gz ${OPT}

You will need to add the `bin` and `lib/python-2.7/site-packages` directories
to `PATH` and `PYTHONPATH` respectively.

Perl
----

Use 

    build_perl.sh perl-5.18.1.tar.gz $OPT

to build and install to `${OPT}/perl/5.18.1`

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

The scripts attempt to version the libraries against different R versions
so to make the packages available:

    export R_LIBS=${SITE_R}/${RVERSION}:$R_LIBS

where `RVERSION` is the `MAJOR.MINOR` version number (for example for
R 3.0.2, `RVERSION=3.0`).

(NB R also supports `R_LIBS_USER` and `R_LIBS_SITE` variables.)

To install Bioconductor packages use:

    install_bioc_package.sh ${OPT}/R/3.0.2/bin/R SRAdb ${SITE_R}

### Comments ###

This is a work in progress.

To check if a package is available do:

    library("<package>")

to try and load it, or

    installed.packages()

to get a list of all the installed packages.

When installing from archive files the archive file name should be in
the format `<NAME>-<VERSION>.tar.gz` i.e. using a hyphen to separate the
name from the version. If a character other than a hyphen is used then
the package name will not be correctly guessed.

To update a CRAN package do

    update.packages("<package>")

Information on managing and upgrading Bioconductor packages can be found
at [http://www.bioconductor.org/install]

The Bioconductor installer is quite inefficient as it updates biocLite.R
each time, and can only be run for one package at a time.
