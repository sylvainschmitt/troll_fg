#!/bin/bash
#SBATCH --time=240:00:00
#SBATCH -J troll_tee
#SBATCH -o troll_tee.%N.%j.out
#SBATCH -e troll_tee.%N.%j.err
#SBATCH --mem=5G
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=ALL
#SBATCH -p unlimitq

# Environment
module purge
module load bioinfo/Snakemake/7.20.0
module load containers/singularity/3.9.9

# Variables
CONFIG=ressources.yaml
COMMAND="sbatch --cpus-per-task={cluster.cpus} --time={cluster.time} --mem={cluster.mem} -J {cluster.jobname} -o snake_subjob_log/{cluster.jobname}.%N.%j.out -e snake_subjob_log/{cluster.jobname}.%N.%j.err"
CORES=200
mkdir -p snake_subjob_log

# Workflow
snakemake --use-singularity -j $CORES --cluster-config $CONFIG --cluster "$COMMAND" --keep-going

