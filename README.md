bioinf-software-install
=======================

**Scripts to help with building and deploying bioinformatics software**

Various scripts to help with building and deploying multiple versions of
software used for bioinformatics, including Python, Perl and R, and
standalone applications such as bowtie.

**This is a work in progress.**

The intention is to provide support for "managed installations" of
different versions of these software which are completely independent of
those provided via the system's package manager (e.g. yum). By
standardising and automating common installation tasks, both the burden
on administrators and the length of time users have to wait for
packages to are reduced.

Overview
--------

The general installation scheme is to have a top-level installation
directory (referred to here by the placeholder variable `OPT`) below
which packages are installed using the directory structure:

    ${OPT}/<PACKAGE>/<VERSION>

e.g. if `OPT` is `/opt/apps/` then `R` 3.0.2 would be installed into

    /opt/apps/R/3.0.2

For specific Python, perl or R libraries we prefer to install to
site-specific locations, e.g.

    ${OPT_LIBS}/site-python
    ${OPT_LIBS}/site-perl
    ${OPT_LIBS}/site-R

within which there is also a level of versioning, e.g.

    /opt/libs/site-R/3.0/...

(The library versioning is based on `MAJOR.MINOR` version numbers, with
the assumption that library packages should be compatible across patch
versions within a given set of `MAJOR.MINOR` versions.)

The installation scheme is intended to be coupled with the use of
[Environment Modules](http://modules.sourceforge.net/) for managing the
user environment. For the `R` example above the accompanying module file
might look like:

    #Module1.0
    ## R 3.0.2
    ##
    prepend-path PATH   /opt/apps/R/3.0.2/bin
    prepend-path R_LIBS /opt/libs/site-R/3.0

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

To install packages under a non-root location (e.g. `SITE_PERL`) directly from
CPAN, use:

    install_perl_package.sh ${OPT}/perl/5.18.1 DBI ${SITE_PERL}

The script uses `cpanm` (from the `App::cpanminus` module) to perform the
installation; it also attempts to version the libraries against different Perl
versions so to make the packages available:

    export PERL5LIB=${SITE_PERL}/${PERLVERSION}/lib/perl5:$PERL5LIB

where `PERLVERSION` is the `MAJOR.MINOR` version number (for example for
R 5.18.1, `PERLVERSION=5.18`).


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

Other packages
--------------

Standalone scripts also exist to build the following bioinformatics
packages:

 * BEDTools
 * freebayes
 * mothur
 * samtools
 * ucsc_tools

and to download and install binary distributions for:

 * NCBI Blast+
 * Bowtie/Bowtie2
 * Cufflinks
 * Fastx toolkit
 * Picard tools
 * Tophat
