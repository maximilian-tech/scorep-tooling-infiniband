#!/bin/env -S bash --noprofile --norc

set -euo pipefail
set -x

if (( $# != 1 )) || [[ $1 != gcc && $1 != intel ]]; then
    printf 'Usage: %s {gcc|intel}\n' "$0" >&2
    exit 1
fi

declare -A MPI_MAP=(
    [gcc]=openmpi
    [intel]=intel3
)
declare -A COMPILER_MAP=(
    [gcc]=gcc
    [intel]=oneapi
)



LINK="https://perftools.pages.jsc.fz-juelich.de/cicd/scorep/branches/MR650/latest.tar.gz"
#LINK="https://perftools.pages.jsc.fz-juelich.de/cicd/scorep/branches/master/latest.tar.gz"
compiler=$1
mpi=${MPI_MAP[$compiler]:-}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "${SCRIPT_DIR}"

if [ ! -d scorep-source ] ; then
    echo "Downloading latest Score-P"
    
    wget -q "$LINK"

    rm -rf scorep-source
    mkdir -p scorep-source
    tar -xzf latest.tar.gz --strip-components=1 -C scorep-source

    rm latest.tar.gz
fi

if [ ! -d "${SCRIPT_DIR}/scorep_install_$compiler" ] ; then
    cd scorep-source
    rm -rf _build_$compiler
    mkdir -p _build_$compiler
    cd _build_$compiler
        ../configure --prefix="${SCRIPT_DIR}/scorep_install_$compiler" \
                    --disable-cuda \
                    --disable-openacc \
                    --without-shmem \
                    --with-libgotcha=download \
                    --with-libunwind=download \
                    --with-libbfd=download \
                    --with-libpapi=download \
                    --with-libhwloc=download \
                    --with-mpi=$mpi \
                    --with-nocross-compiler-suite="${COMPILER_MAP[$compiler]:?}"
        make -j 8
        make install
    cd ../../
fi
