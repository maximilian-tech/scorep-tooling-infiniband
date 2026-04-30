#!/usr/bin/env bash
#SBATCH -N 2
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:30:00
#SBATCH --cpu-freq=high



set -euo pipefail

source source_env_foss

export SCOREP_METRIC_PLUGINS=infiniband_plugin      # required
#export SCOREP_METRIC_INFINIBAND_PLUGIN='*'          # required
export SCOREP_METRIC_INFINIBAND_PLUGIN_INTERVAL=5  # (optional) Sampling interval in ms
export INFINIBAND_PLUGIN_VERBOSE=WARN # FATAL, ERROR, WARN, INFO, DEBUG

export SCOREP_METRIC_INFINIBAND_PLUGIN='port_xmit_data,port_xmit_packets,port_rcv_data,port_rcv_packets,rx_atomic_requests,rx_dct_connect,rx_read_requests,rx_write_requests'          # required

export SCOREP_ENABLE_PROFILING=0 # Required
export SCOREP_ENABLE_TRACING=1
export SCOREP_TOTAL_MEMORY=1G
export SCOREP_METRIC_PERF=cache-misses,cycles,cpu-clock


EXE="/data/horse/ws/s0872522-osu_benchmarks/osu_foss_scorep/libexec/osu-micro-benchmarks/mpi/one-sided/osu_put_bw"

srun lo2s --output-trace lo2s_trace_rank_{ENV=SLURM_PROCID} --count 1000000 --call-graph --standard-metrics  -- "${EXE}"


