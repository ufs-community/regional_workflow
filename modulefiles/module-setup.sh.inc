# Create a test function for sh vs. bash detection.  The name is
# randomly generated to reduce the chances of name collision.
__ms_function_name="setup__test_function__$$"
eval "$__ms_function_name() { /bin/true ; }"

# Determine which shell we are using
__ms_ksh_test=$( eval '__text="text" ; if [[ $__text =~ ^(t).* ]] ; then printf "%s" ${.sh.match[1]} ; fi' 2> /dev/null | cat )
__ms_bash_test=$( eval 'if ( set | grep '$__ms_function_name' | grep -v name > /dev/null 2>&1 ) ; then echo t ; fi ' 2> /dev/null | cat )

if [[ ! -z "$__ms_ksh_test" ]] ; then
    __ms_shell=ksh
elif [[ ! -z "$__ms_bash_test" ]] ; then
    __ms_shell=bash
else
    # Not bash or ksh, so assume sh.
    __ms_shell=sh
fi

if [[ -d /lfs4 ]] ; then
    # We are on NOAA Jet
    if ( ! eval module help > /dev/null 2>&1 ) ; then
        source /apps/lmod/lmod/init/$__ms_shell
    fi
    module purge
elif [[ -d /scratch3 ]] ; then
    # We are on NOAA Theia
    if ( ! eval module help > /dev/null 2>&1 ) ; then
        source /apps/lmod/lmod/init/$__ms_shell
    fi
    module purge
elif [[ -d /gpfs/hps && -e /etc/SuSE-release ]] ; then
    # We are on NOAA Luna or Surge
    if ( ! eval module help > /dev/null 2>&1 ) ; then
       source /opt/modules/default/init/$__ms_shell
    fi
    module purge
    module purge
    # Workaround until module issues are fixed:
    unset _LMFILES_
    unset LOADEDMODULES
    module use /opt/modulefiles
    module use /opt/cray/ari/modulefiles
    module use /opt/cray/craype/default/alt-modulefiles
    module use /opt/cray/alt-modulefiles
    module use /gpfs/hps/nco/ops/nwprod/modulefiles
    module use /gpfs/hps/nco/ops/nwprod/lib/modulefiles
    module use /usrx/local/prod/modulefiles
elif [[ -d /dcom && -d /hwrf ]] ; then
    # We are on NOAA Tide or Gyre
    if ( ! eval module help > /dev/null 2>&1 ) ; then
        source /usrx/local/Modules/default/init/$__ms_shell
    fi
    module purge
elif [[ -L /usrx && "$( readlink /usrx 2> /dev/null )" =~ dell ]] ; then
    # We are on NOAA Mars or Venus
    if ( ! eval module help > /dev/null 2>&1 ) ; then
	source /usrx/local/prod/lmod/lmod/init/$__ms_shell
    fi
    module purge
elif [[ -d /lustre && -d /ncrc ]] ; then
    # We are on GAEA. Nothing to do.
else
    echo WARNING: UNKNOWN PLATFORM 1>&2
fi

unset __ms_shell
unset __ms_ksh_test
unset __ms_bash_test
unset $__ms_function_name
unset __ms_function_name
