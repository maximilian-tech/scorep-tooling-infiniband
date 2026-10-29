#!/bin/env -S bash --noprofile --norc

set -euo pipefail
set -x

if (( $# != 1 )) || [[ $1 != ompi && $1 != intel && $1 != mpich ]]; then
    printf 'Usage: %s {ompi|intel|mpich}\n' "$0" >&2
    exit 1
fi

declare -A COMPILER_MAP=(
    [ompi]=gcc
    [intel]=oneapi
    [mpich]=clang
)


compiler=$1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "${SCRIPT_DIR}"

if [ ! -d lo2s-source ] ; then
    echo "Downloading latest Score-P"

    rm -rf lo2s-source
    mkdir -p lo2s-source
    git clone --recursive --branch relax_otf2_version_req https://github.com/maximilian-tech/lo2s.git lo2s-source
fi

export CPLUS_INCLUDE_PATH=/home/s0872522/Downloads/elfutils-0.192

if [ ! -d "${SCRIPT_DIR}/lo2s_install_$compiler" ] ; then
    cd lo2s-source
    rm -rf _build_$compiler
    mkdir -p _build_$compiler
    cd _build_$compiler
        cmake ../ --fresh \
	  -DCMAKE_INSTALL_PREFIX="${SCRIPT_DIR}/lo2s_install_$compiler" \
	  -DUSE_BPF:BOOL=OFF \
	  -DOTF2XX_RELAX_OTF2VERSION_REQUIREMENT=ON \
	  -DUSE_DEBUGINFOD=ON \
	  -DDebuginfod_LIBRARY=/usr/lib64/libdebuginfod.so.1 \
	  -DCMAKE_BUILD_TYPE=Release

       		  	
        make -j 8
        make install
    cd ../../
fi
