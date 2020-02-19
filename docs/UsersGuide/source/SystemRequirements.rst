*******************
System Requirements
*******************
The UFS-CAM Community Workflow is supported on the NOAA HPC Hera and NCAR
Supercomputer Cheyenne.  Intel and GNU are the currently supported
compilers for building the pre-processing utilities, the UFS Weather Model,
and the Unified Post Processor (UPP).

.. _SystemRequirements:

======================================
Software/Operating System Requirements
======================================
This sections lists the external system and software requirements for building and
running all tasks in the UFS-CAM Community Workflow. 

* UNIX style operating system
* Fortran compiler with support for Fortran 2003 (Intel or GNU compiler)
* python >= 2.7
* perl 5
* git client (1.8 or greater)
* C compiler
* MPI
* ESMFv8.0.0_bs40
* netCDF
* HDF5
* pnetCDF
* NCEPLIBS
* CMake 3.15 or newer
* Rocoto Workflow Management System (1.3.1)

==============
NCEP Libraries
==============
A number of the NCEP (National Center for Environmental Prediction) production
libraries are necessary for building and running the pre-processing utilities,
the UFS Weather Model and UPP.  These libraries are not part of the
FV3SAR Community Workflow source code distribution.  If they are not already installed on
your computer platform, you may have to clone the source code from the
`github repository <https://github.com/NOAA-EMC/NCEPLIBS>`_ and follow the build instructions
in the `wiki page <https://github.com/NOAA-EMC/NCEPLIBS/wiki/Cloning-and-Compiling-NCEPLIBS>`_.
Note that these libraries must be built with the same compiler used to build the pre-processing utilities,
the UFS Weather Model and the UPP.

.. note::
  The NCEPLIBS github repository contains versions of the pre-processor chgres_cube and UPP used by
  the global model as well as other tools such as hfd5, jasper, zlib, etc.
