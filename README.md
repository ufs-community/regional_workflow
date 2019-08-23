# regional_workflow

# Build and install the regional workflow
1. Check out the regional workflow external components:

`./manage_externals/checkout_externals`

`cd sorc`

2. Build the regional workflow system:

`./build_all.sh`

3. Install the executables:

`./install_all.sh`

4. Link the fix files:

`./link_fix.sh`

5. Modify `HOMEfv3`, `CPU_ACCOUNT`, `COMINgfs`, `STMP`, and `PTMP` in the `run_regional_${machine}.sh`
   (where machine is `theia`, `wcoss_Dell_p3`, etc.):

`cd rocoto`
`vi ./run_regional_${machine}.sh`

6. Run the edited script from step 5 to generate workflow definition file and run the workflow:

`./run_regional_${machine}.sh`

6. Check status of run:

`rocotostat -v 10 -w fv3sartest_2019050200.xml -d fv3sartest_2019050200.db`

7. Continue to type the rocotorun command or add the appropriate command to your crontab:

`*/3 * * * * cd /path/to/regional_workflow/rocoto && rocotorun -v 10 -w fv3sartest_2019050200.xml -d fv3sartest_2019050200.db`

