#!/usr/bin/env bash

set -euxo pipefail

cp "${RECIPE_DIR}/make.inc" "${SRC_DIR}/make.inc"
cd "${SRC_DIR}"

# MPI support
cat >> make.inc <<EOF

COMMS = mpi
MPIF90 = ${PREFIX}/bin/mpif90
EOF

# Wannier90's MPI wrapper routines may trigger strict argument-mismatch errors with
# modern gfortran, so append the compatibility flag for such cases.
if [[ "${FC:-}" == *gfortran* ]] && ! grep -q -- '-fallow-argument-mismatch' make.inc; then
  sed -i 's|^FCOPTS = .*|& -fallow-argument-mismatch|' make.inc
fi

make wannier -j "${CPU_COUNT:-1}"

# TODO this breaks compilation - TBD
# if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
#   make test-serial -j "${CPU_COUNT:-1}"
# fi

echo "===== Effective make.inc ====="
cat make.inc
echo "=============================="

make install PREFIX="${PREFIX}"
