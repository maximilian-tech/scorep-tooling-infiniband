#!/bin/env -S bash --noprofile --norc

set -euo pipefail
set -x

if (( $# != 1 )) || [[ $1 != ompi && $1 != intel && $1 != mpich ]]; then
    printf 'Usage: %s {ompi|intel|mpich}\n' "$0" >&2
    exit 1
fi

compiler=$1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "${SCRIPT_DIR}"

if [ ! -d scorep_plugin_infiniband ] ; then
    git clone --recursive git@github.com:score-p/scorep_plugin_infiniband.git scorep_plugin_infiniband
fi

if [ ! -d "${SCRIPT_DIR}/scorep_plugin_infiniband_install_$compiler" ] ; then
    cd "${SCRIPT_DIR}/scorep_plugin_infiniband"
    rm -rf _build
    mkdir -p _build
    cd _build
    cmake .. --fresh \
      -DCMAKE_INSTALL_PREFIX="${SCRIPT_DIR}/scorep_plugin_infiniband_install_$compiler" \
      -DCMAKE_BUILD_TYPE=Release
    make -B
    make install
    cd ../../
fi
