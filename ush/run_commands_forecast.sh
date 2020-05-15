
# these should be coming from RESOURCE statements in .xml file

  export TOTAL_TASKS=${TOTAL_TASKS:-1824}

  export NCTSK=${NCTSK:-12}
  export NCNODE=${NCNODE:-24}
  export OMP_NUM_THREADS=${OMP_THREADS:-${OMP_NUM_THREADS:-2}}
  export KMP_STACKSIZE=1024m
  export KMP_AFFINITY=disabled
if [ "$machine" = wcoss_cray ]; then
  #export NODES=1
  export APRUNS=${APRUNS:-"aprun -b -j1 -n1 -N1 -d1 -cc depth"}
  export APRUNF=${APRUNF:-"aprun -b -j1 -n${TOTAL_TASKS} -N${NCTSK} -d${OMP_NUM_THREADS} -cc depth cfp"}
  export APRUNC=${APRUNC:-"aprun -b -j1 -n${TOTAL_TASKS} -N${NCTSK} -d${OMP_NUM_THREADS} -cc depth"}
  export APRUNO="time"
  export BACKGROUND=""
elif [ "$machine" = wcoss_dell_p3 ]; then
  export APRUNS=${APRUNS:-"time"}
  export APRUNF=${APRUNF:-"mpirun cfp"}
  export APRUNC=${APRUNC:-"mpirun"}
  export APRUNO="time"
  export BACKGROUND=""
elif [ "$machine" = hera ]; then
  export APRUNS=${APRUNS:-"srun --ntasks=1 --ntasks-per-node=1 --cpus-per-task=1"}
  #export APRUNF=${APRUNF:-"srun --ntasks=${TOTAL_TASKS} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS} --multi-prog"}
  export APRUNF=${APRUNF:-"time"}
  export APRUNC=${APRUNC:-"srun --ntasks=${TOTAL_TASKS} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  #export APRUNO=${APRUNO:-"srun --ntasks=1 --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNO=${APRUNO:-"srun --ntasks=1 --ntasks-per-node=1 --cpus-per-task=1"}
  export BACKGROUND="&"
elif [ "$machine" = orion ]; then
  export APRUNS=${APRUNS:-"srun --ntasks=1 --ntasks-per-node=1 --cpus-per-task=1"}
  #export APRUNF=${APRUNF:-"srun --ntasks=${TOTAL_TASKS} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS} --multi-prog"}
  export APRUNF=${APRUNF:-"time"}
  export APRUNC=${APRUNC:-"srun --ntasks=${TOTAL_TASKS} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  #export APRUNO=${APRUNO:-"srun --ntasks=1 --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNO=${APRUNO:-"srun --ntasks=1 --ntasks-per-node=1 --cpus-per-task=1"}
  export BACKGROUND="&"
elif [ "$machine" = jet ]; then
  export APRUNS=${APRUNS:-"srun --ntasks=1 --ntasks-per-node=1 --cpus-per-task=1"}
  #export APRUNF=${APRUNF:-"srun --ntasks=${TOTAL_TASKS} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS} --multi-prog"}
  export APRUNF=${APRUNF:-"time"}
  export APRUNC=${APRUNC:-"srun --ntasks=${TOTAL_TASKS} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  #export APRUNO=${APRUNO:-"srun --ntasks=1 --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNO=${APRUNO:-"srun --ntasks=1 --ntasks-per-node=1 --cpus-per-task=1"}
  export BACKGROUND="&"
else
  export APRUNS=${APRUNS:-"time"}
  export APRUNF=${APRUNF:-${MPISERIAL:-mpiserial}}
  export APRUNC=${APRUNC:-"mpirun"}
  export APRUNO="time"
  export BACKGROUND=""
fi
