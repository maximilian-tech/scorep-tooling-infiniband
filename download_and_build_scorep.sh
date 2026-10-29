#!/bin/env -S bash --noprofile --norc

set -euo pipefail
set -x

if (( $# != 1 )) || [[ $1 != ompi && $1 != intel && $1 != mpich ]]; then
    printf 'Usage: %s {ompi|intel|mpich}\n' "$0" >&2
    exit 1
fi

declare -A MPI_MAP=(
    [ompi]=openmpi
    [intel]=intel3
    [mpich]=mpich3
)
declare -A COMPILER_MAP=(
    [ompi]=gcc
    [intel]=oneapi
    [mpich]=clang
)



LINK="https://perftools.pages.jsc.fz-juelich.de/cicd/scorep/branches/MR650/latest.tar.gz"
#LINK="https://perftools.pages.jsc.fz-juelich.de/cicd/scorep/branches/master/latest.tar.gz"
compiler=${COMPILER_MAP[$1]:?}
mpi=${MPI_MAP[$1]:-}
tc_name=$1

echo $mpi
echo $compiler

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

if [ ! -d "${SCRIPT_DIR}/scorep_install_$tc_name" ] ; then
    cd scorep-source
    rm -rf _build_$tc_name
    mkdir -p _build_$tc_name
    cd _build_$tc_name
        ../configure --prefix="${SCRIPT_DIR}/scorep_install_$tc_name" \
                    --disable-cuda \
                    --disable-openacc \
                    --with-libgotcha=download \
                    --with-libunwind=download \
                    --with-libbfd=download \
                    --with-libpapi=download \
                    --with-libhwloc=download \
                    --with-mpi=$mpi \
                    --with-nocross-compiler-suite=$compiler
        make -j 8
        make install
    cd ../../
fi
