#!/bin/bash 

set -x
singularity exec -e -B /home:/home -B /lustre:/lustre -B /contrib:/contrib /contrib/Mark.Potts/ubuntu20.04-epic-srwapp.sif /lustre/ufs-srweather-app/regional_workflow/ush/load_modules_run_task.sh $*
