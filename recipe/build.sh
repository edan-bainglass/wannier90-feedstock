#!/usr/bin/env bash

set -euxo pipefail

cp "${RECIPE_DIR}/make.inc" "${SRC_DIR}/make.inc"
cd "${SRC_DIR}"

# MPI support
cat >> make.inc <<EOF

COMMS = mpi
MPIF90 = ${PREFIX}/bin/mpif90
EOF

# Wannier90's MPI wrapper routines may trigger strict argument-mismatch errors
# with modern gfortran.
if [[ "${FC:-}" == *gfortran* ]] &&
   ! grep -q -- '-fallow-argument-mismatch' make.inc; then
  sed 's|^FCOPTS = .*|& -fallow-argument-mismatch|' \
    make.inc > make.inc.tmp
  mv make.inc.tmp make.inc
fi

echo "===== Effective make.inc ====="
cat make.inc
echo "=============================="

make install PREFIX="${PREFIX}"
