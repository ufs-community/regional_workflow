***************************************
Software Installation
***************************************

===========================================
System Requirements
===========================================
The FV3SAR model is supported on the NOAA HPC Theia and NCAR
Supercomputer Cheyenne.  Intel is the only currently supported
compiler for building the pre-processing utilities and the FV3SAR model.

-------------------------------------------
External Libraries
-------------------------------------------
Several external support libraries are required but not included with
the source code.  Most of these libraries are installed as part of the
compiler installation.  For FV3SAR, these libraries are:

* Intel compiler
* impi
* ESMFv7.1.0
* netCDF
* HDF5
* pnetCDF

-------------------------------------------
NCEP Libraries
-------------------------------------------
A number of the NCEP (National Center for Environmental Prediction) production
libraries are necessary for building and running the FV3SAR pre-processing utilities
and model (Table `1`_).  These libraries are not part of the source
code distribution.  If they are not already installed on your computer platform, you may
have to download some or all the source code from `NCEP <http://www.nco.ncep.noaa.gov/pmb/codes/nwprod/>`_
and build the libraries yourself.  Note that these libraries must be built with the same compiler
used to build the pre-processing utilities FV3SAR model.  Another option is to clone the `git
repository <https://github.com/NCAR/NCEPlibs.git>`_ and follow the build instructions.
This currently includes only the libraries used by the FV3SAR model.

.. _1:

.. table:: Table 1:  NCEP libraries necessary to build the FV3SAR pre-processing utilities and the model.
   X indicates that the library is required.

   +------------------------+----------------------+-------------+
   | **NCEP Library**       | **Pre-Processing**   |  **FV3SAR** |
   +========================+======================+=============+
   | ``bacio/v2.0.1``       |                      | X           |
   +------------------------+----------------------+-------------+
   | ``bacio/v2.0.2``       |  X                   |             |
   +------------------------+----------------------+-------------+
   | ``gfsio/v1.1.0``       |  X                   |             |
   +------------------------+----------------------+-------------+
   | ``ip/v2.0.0``          |  X                   | X           |
   +------------------------+----------------------+-------------+
   | ``ip/v3.0.0``          |  X                   |             |
   +------------------------+----------------------+-------------+
   | ``landsfcutil/v2.1.0`` |  X                   |             |
   +------------------------+----------------------+-------------+
   | ``nemsio/v2.2.3``      |  X                   | X           |
   +------------------------+----------------------+-------------+
   | ``nemsiogfs/v2.0.1``   |  X                   |             |
   +------------------------+----------------------+-------------+
   | ``sfcio/v1.0.0``       |  X                   |             |
   +------------------------+----------------------+-------------+
   | ``sigio/v2.0.1``       |  X                   |             |
   +------------------------+----------------------+-------------+
   | ``sp/v2.0.2``          |  X                   | X           |
   +------------------------+----------------------+-------------+
   | ``w3emc/v2.0.5``       |  X                   | X           |
   +------------------------+----------------------+-------------+
   | ``w3emc/v2.2.0``       |  X                   |             |
   +------------------------+----------------------+-------------+
   | ``w3nco/v2.0.6``       |  X                   | X           |
   +------------------------+----------------------+-------------+

.. _ObtainingCode:

===========================================
Obtaining the FV3SAR Source Code
===========================================
In order to run FV3SAR, the user must first get the NEMSfv3gfs
model code, and the fv3gfs preprocessing programs and workflow
scripts. This step assumes the necessary NCEP libraries are
built and available as modules on your machine. 

The source code for the FV3SAR pre-processing utilities and the
regional model reside in two separate NOAA VLAB repositories. 
You will need a NOAA account to check out the code; the ``${USER}``
variable used below is your NEMS User ID, not to be confused with the NEMS 
(NOAA Environmental Modeling System) infrastructure.
The pre-processing and workflow utilities are located in the
fv3gfs_workflow repository.  To clone this repository, create a
directory called ``${TOP_DIR}``, clone the repository and check out the
``community`` branch:

.. code-block:: console

   % mkdir ${TOP_DIR}
   % cd ${TOP_DIR}
   % git clone ssh://${USER}@vlab.ncep.noaa.gov:29418/fv3sar_workflow
   % cd fv3sar_workflow
   % git checkout community

The model source code is located in the NEMSfv3gfs repository, which includes
three submodules: FMS, FV3, and NEMS.  You will need to clone the main repository,
checkout the ``regional_fv3_nemsfv3gfs`` branch, and check out the appropriate
branch for each submodule:

.. code-block:: console

   % cd ${TOP_DIR}
   % git clone --recursive ssh://${USER}@vlab.ncep.noaa.gov:29418/NEMSfv3gfs
   % cd NEMSfv3gfs
   % git checkout regional_fv3_nemsfv3gfs
   % cd FV3
   % git checkout regional_fv3
   % cd ${TOP_DIR}/NEMSfv3gfs
   % cd FMS
   % git checkout GFS-FMS
   % cd ${TOP_DIR}/NEMSfv3gfs
   % cd NEMS
   % git checkout master

===========================================
Building the FV3SAR Source Code
===========================================
To run the end-to-end FV3SAR forecasting system, the pre-processing utilities,
the FV3SAR model, and the post-porcessing components must be built.  This section
describes the steps for the supported compilers on the available platforms.  The
directory ``${TOP_DIR}`` is assumed to be where the code has been checked
out as described in Section ObtainingCode_.

To build the FV3SAR pre-processing utilities on theia:

.. code-block:: console

   % cd ${TOP_DIR}/fv3sar_workflow/regional
   % ./build_regional theia >& out.build_regional

Other supported build platforms are ``"cheyenne``, ``wcoss_cray``, or ``odin``.
When the build completes, there should be 9 executables under ``${TOP_DIR}/fv3sar_workflow/exec``:

.. code-block:: console

   % ls ${TOP_DIR}/fv3sar_workflow/exec
   filter_topo        global_chgres         make_solo_mosaic
   fregrid            make_hgrid            ml01rg2.x       
   fregrid_parallel   make_hgrid_parallel   shave.x         

To build the FV3 model executable:

.. code-block:: console

   % cd ${TOP_DIR}/NEMSfv3gfs/tests
   % ./compile.sh ${TOP_DIR}/NEMSfv3gfs/FV3 theia.intel "32BIT=Y" 32bit YES NO >& make.out.32bit

Note that the second argument is ``theia.intel``, not just ``theia``.  Other build targets are:
``cheyenne.gnu, cheyenne.intel, cheyenne.pgi, odin, theia.gnu, theia.intel, theia.pgi`` or ``wcoss_cray``.

This is a production build, not a debug build.  We don't do the debug build because it is very slow
to run, and you'll time out in the queue.  The build takes about 12 minutes.  If successful, there
should be a file named ``fv3_32bit.exe`` in the directory ``${TOP_DIR}/NEMSfv3gfs/tests``.

There are other command-line options available when running ``compile.sh`` and are shown in Table `2`_.

.. _2:

.. table:: Table 2: Command-line options to build FV3SAR.

   +---------------------+-----------------------+---------------------------------+--------------+
   | **Argument Number** | **Argument Name**     |  **Example**                    | **Optional** |
   +=====================+=======================+=================================+==============+
   | 1                   | path to FV3 directory | ``${PWD}../FV3``                | No           | 
   +---------------------+-----------------------+---------------------------------+--------------+
   | 2                   | ``BUILD_TARGET``      | ``theia.intel, cheyenne.intel`` | No           |
   +---------------------+-----------------------+---------------------------------+--------------+
   | 3                   | ``MAKE_OPT``          | ``DEBUG=Y 32BIT=Y REPRO=N``     | Yes          |
   +---------------------+-----------------------+---------------------------------+--------------+
   | 4                   | ``BUILD_NAME``        | ``32bit``                       | Yes          |
   +---------------------+-----------------------+---------------------------------+--------------+
   | 5                   | ``clean_before``      | ``YES``                         | Yes          |
   +---------------------+-----------------------+---------------------------------+--------------+
   | 6                   | ``clean_after``       | ``YES``                         | Yes          |
   +---------------------+-----------------------+---------------------------------+--------------+

To build with debugging flags, add the following quantities to the ``compile.sh`` command:

.. code-block:: console

   % ./compile.sh ../FV3 ${BUILD_TARGET} "32BIT=Y DEBUG=Y" 32bit [clean_before] [clean_after] >& make.out.32bit

The last two optional arguments ``clean_before`` and ``clean_after`` control whether or not to run
make clean to remove temporary files. The default values are ``YES``. Specifying ``NO`` will skip
cleaning step, which will speed up repeating compilation, which is useful for debugging.

Currently all the fixed fields necessary to run a uniform global case without a nest are in subdirectories
on each supported machine:

*  ``/gpfs/hps3/emc/global/noscrub/emc.glopara/git/fv3gfs/fix/fix_fv3`` on the cray
*  ``/scratch4/NCEPDEV/global/save/glopara/git/fv3gfs/fix/fix_fv3`` on theia
*  ``/glade/p/ral/jntp/GMTB/FV3GFS_V1_RELEASE/fix/fix_am/`` on Cheyenne

