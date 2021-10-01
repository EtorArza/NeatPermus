#!/bin/bash
###   s b a t c h --array=1-$runs:1 $SL_FILE_NAME
#SBATCH --output=out/slurm_%A_%a_out.txt
#SBATCH --error=out/slurm_%A_%a_err.txt
#SBATCH --ntasks=1 # number of tasks
#SBATCH --ntasks-per-node=1 #number of tasks per node
#SBATCH --mem=8G
#SBATCH --cpus-per-task=16 # number of CPUs
#SBATCH --time=5-00:00:00 #Walltime
#SBATCH -p large
#SBATCH --exclude=n[001-004]


SCRATCH_JOB=${SCRATCH_JOB}_${SLURM_ARRAY_TASK_ID}
mkdir ${SCRATCH_JOB}

source scripts/array_to_string_functions.sh


SRCDIR=`pwd`
EXPERIMENT_CONTROLLER_FOLDER_NAME="${SRCDIR}/${EXPERIMENT_CONTROLLER_FOLDER_NAME}"




list_to_array $CONTROLLER_NAME_PREFIX_ARRAY
CONTROLLER_NAME_PREFIX_ARRAY=("${BITRISE_CLI_LAST_PARSED_LIST[@]}")
CONTROLLER_NAME_PREFIX=${CONTROLLER_NAME_PREFIX_ARRAY[$SLURM_ARRAY_TASK_ID]}

list_to_array $SEED_ARRAY
SEED_ARRAY=("${BITRISE_CLI_LAST_PARSED_LIST[@]}")
SEED=${SEED_ARRAY[$SLURM_ARRAY_TASK_ID]}



list_to_array $FULL_MODEL_ARRAY
FULL_MODEL_ARRAY=("${BITRISE_CLI_LAST_PARSED_LIST[@]}")
FULL_MODEL=${FULL_MODEL_ARRAY[$SLURM_ARRAY_TASK_ID]}


replaced_with=","
COMMA_SEPARATED_PROBLEM_INDEX_LIST_ARRAY=${COMMA_SEPARATED_PROBLEM_INDEX_LIST_ARRAY//"s_e_p"/$replaced_with}
list_to_array $COMMA_SEPARATED_PROBLEM_INDEX_LIST_ARRAY
COMMA_SEPARATED_PROBLEM_INDEX_LIST_ARRAY=("${BITRISE_CLI_LAST_PARSED_LIST[@]}")
COMMA_SEPARATED_PROBLEM_INDEX_LIST=${COMMA_SEPARATED_PROBLEM_INDEX_LIST_ARRAY[$SLURM_ARRAY_TASK_ID]}


replaced_with=","
COMMA_SEPARATED_PROBLEM_DIM_LIST_ARRAY=${COMMA_SEPARATED_PROBLEM_DIM_LIST_ARRAY//"s_e_p"/$replaced_with}
list_to_array $COMMA_SEPARATED_PROBLEM_DIM_LIST_ARRAY
COMMA_SEPARATED_PROBLEM_DIM_LIST_ARRAY=("${BITRISE_CLI_LAST_PARSED_LIST[@]}")
COMMA_SEPARATED_PROBLEM_DIM_LIST=${COMMA_SEPARATED_PROBLEM_DIM_LIST_ARRAY[$SLURM_ARRAY_TASK_ID]}









echo -n "SLURM_ARRAY_TASK_ID: "
echo $SLURM_ARRAY_TASK_ID


cp neat -v $SCRATCH_JOB
#cp src/experiments/real/real_func_src/jani_ronkkonen_problem_generator/quad_function.dat -v --parents $SCRATCH_JOB/

cd $SCRATCH_JOB

echo "pwd: `pwd`"




cat > tmp.ini <<EOF

[Global] 
mode = train
PROBLEM_NAME = real_func

POPSIZE = ${NEAT_POPSIZE}
MAX_TRAIN_ITERATIONS = ${MAX_TRAIN_ITERATIONS}
MAX_TRAIN_TIME = ${MAX_TRAIN_TIME}
THREADS = ${SLURM_CPUS_PER_TASK}
EXPERIMENT_FOLDER_NAME = ${EXPERIMENT_CONTROLLER_FOLDER_NAME}
CONTROLLER_NAME_PREFIX = ${CONTROLLER_NAME_PREFIX}
FULL_MODEL = ${FULL_MODEL}


SEARCH_TYPE = phased
SEED = ${SEED}



MAX_SOLVER_FE = ${MAX_SOLVER_FE}
SOLVER_POPSIZE = ${SOLVER_POPSIZE}



COMMA_SEPARATED_PROBLEM_INDEX_LIST = ${COMMA_SEPARATED_PROBLEM_INDEX_LIST}
COMMA_SEPARATED_PROBLEM_DIM_LIST = ${COMMA_SEPARATED_PROBLEM_DIM_LIST}
EOF


echo "---conf file begin---"

cat tmp.ini

echo "---conf file end---"


date
srun neat "tmp.ini"
date

rm neat