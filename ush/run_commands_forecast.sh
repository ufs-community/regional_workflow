# 
# include this top portion?

  export TOTAL_TASKS=${TOTAL_TASKS:-1824}
  export TOTAL_TASKS_FG=${TOTAL_TASKS_FG:-1296}
  export TOTAL_TASKS_AK=${TOTAL_TASKS_AK:-1632}
  export TOTAL_TASKS_PR=${TOTAL_TASKS_PR:-240}
  export TOTAL_TASKS_HI=${TOTAL_TASKS_HI:-168}
  export TOTAL_TASKS_GUAM=${TOTAL_TASKS_GUAM:-168}

  export TOTAL_TASKS_POST=${TOTAL_TASKS:-72}
  export TOTAL_TASKS_POSTGOES=${TOTAL_TASKS:-180}

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
  export APRUNC_FG=${APRUNC_FG:-"aprun -b -j1 -n${TOTAL_TASKS_FG} -N${NCTSK} -d${OMP_NUM_THREADS} -cc depth"}
  export APRUNC_AK=${APRUNC_AK:-"aprun -b -j1 -n${TOTAL_TASKS_AK} -N${NCTSK} -d${OMP_NUM_THREADS} -cc depth"}
  export APRUNC_PR=${APRUNC_PR:-"aprun -b -j1 -n${TOTAL_TASKS_PR} -N${NCTSK} -d${OMP_NUM_THREADS} -cc depth"}
  export APRUNC_HI=${APRUNC_HI:-"aprun -b -j1 -n${TOTAL_TASKS_HI} -N${NCTSK} -d${OMP_NUM_THREADS} -cc depth"}
  export APRUNC_GUAM=${APRUNC_GUAM:-"aprun -b -j1 -n${TOTAL_TASKS_GUAM} -N${NCTSK} -d${OMP_NUM_THREADS} -cc depth"}
  export APRUNC_POST=${APRUNC_POST:-"aprun -b -j1 -n${TOTAL_TASKS_POST} -N${NCTSK} -d${OMP_NUM_THREADS} -cc depth"}
  export APRUNC_POSTGOES=${APRUNC_POSTGOES:-"aprun -b -j1 -n${TOTAL_TASKS_POSTGOES} -N${NCTSK} -d${OMP_NUM_THREADS} -cc depth"}
  export APRUNO="time"
  export BACKGROUND=""
elif [ "$machine" = wcoss_dell_p3 ]; then
  export APRUNS=${APRUNS:-"time"}
  export APRUNF=${APRUNF:-"mpirun cfp"}
  export APRUNC=${APRUNC:-"mpirun"}
  export APRUNC_FG=${APRUNC_FG:-"mpirun"}
  export APRUNC_AK=${APRUNC_AK:-"mpirun"}
  export APRUNC_PR=${APRUNC_PR:-"mpirun"}
  export APRUNC_HI=${APRUNC_HI:-"mpirun"}
  export APRUNC_GUAM=${APRUNC_GUAM:-"mpirun"}
  export APRUNC_POST=${APRUNC_POST:-"mpirun"}
  export APRUNC_POSTGOES=${APRUNC_POSTGOES:-"mpirun"}
  export APRUNO="time"
  export BACKGROUND=""
elif [ "$machine" = theia ]; then
  export APRUNS=${APRUNS:-"srun --ntasks=1 --ntasks-per-node=1 --cpus-per-task=1"}
  #export APRUNF=${APRUNF:-"srun --ntasks=${TOTAL_TASKS} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS} --multi-prog"}
  export APRUNF=${APRUNF:-"time"}
  export APRUNC=${APRUNC:-"srun --ntasks=${TOTAL_TASKS} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNC_FG=${APRUNC_FG:-"srun --ntasks=${TOTAL_TASKS_FG} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNC_AK=${APRUNC_AK:-"srun --ntasks=${TOTAL_TASKS_AK} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNC_PR=${APRUNC_PR:-"srun --ntasks=${TOTAL_TASKS_PR} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNC_HI=${APRUNC_HI:-"srun --ntasks=${TOTAL_TASKS_HI} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNC_GUAM=${APRUNC_GUAM:-"srun --ntasks=${TOTAL_TASKS_GUAM} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNC_POST=${APRUNC_POST:-"srun --ntasks=${TOTAL_TASKS_POST} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNC_POSTGOES=${APRUNC_POSTGOES:-"srun --ntasks=${TOTAL_TASKS_POSTGOES} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  #export APRUNO=${APRUNO:-"srun --ntasks=1 --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNO=${APRUNO:-"srun --ntasks=1 --ntasks-per-node=1 --cpus-per-task=1"}
  export BACKGROUND="&"
elif [ "$machine" = jet ]; then
  export APRUNS=${APRUNS:-"srun --ntasks=1 --ntasks-per-node=1 --cpus-per-task=1"}
  #export APRUNF=${APRUNF:-"srun --ntasks=${TOTAL_TASKS} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS} --multi-prog"}
  export APRUNF=${APRUNF:-"time"}
  export APRUNC=${APRUNC:-"srun --ntasks=${TOTAL_TASKS} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNC_FG=${APRUNC_FG:-"srun --ntasks=${TOTAL_TASKS_FG} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNC_AK=${APRUNC_AK:-"srun --ntasks=${TOTAL_TASKS_AK} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNC_PR=${APRUNC_PR:-"srun --ntasks=${TOTAL_TASKS_PR} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNC_POST=${APRUNC_POST:-"srun --ntasks=${TOTAL_TASKS_POST} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNC_POSTGOES=${APRUNC_POSTGOES:-"srun --ntasks=${TOTAL_TASKS_POSTGOES} --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  #export APRUNO=${APRUNO:-"srun --ntasks=1 --ntasks-per-node=${NCTSK} --cpus-per-task=${OMP_NUM_THREADS}"}
  export APRUNO=${APRUNO:-"srun --ntasks=1 --ntasks-per-node=1 --cpus-per-task=1"}
  export BACKGROUND="&"
else
  export APRUNS=${APRUNS:-"time"}
  export APRUNF=${APRUNF:-${MPISERIAL:-mpiserial}}
  export APRUNC=${APRUNC:-"mpirun"}
  export APRUNC_FG=${APRUNC_FG:-"mpirun"}
  export APRUNC_AK=${APRUNC_AK:-"mpirun"}
  export APRUNC_PR=${APRUNC_PR:-"mpirun"}
  export APRUNC_HI=${APRUNC_HI:-"mpirun"}
  export APRUNC_GUAM=${APRUNC_GUAM:-"mpirun"}
  export APRUNC_POST=${APRUNC_POST:-"mpirun"}
  export APRUNC_POSTGOES=${APRUNC_POSTGOES:-"mpirun"}
  export APRUNO="time"
  export BACKGROUND=""
fi
