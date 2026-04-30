#!/usr/bin/env bash
#SBATCH -N 4
#SBATCH --ntasks-per-node=8
#SBATCH --time=00:30:00

set -euo pipefail

srun lo2s --o lo2s_trace_rank_{ENV=SLURM_PROCID} -- ./my_application
