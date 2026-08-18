#! /bin/bash

set -euo pipefail

mamba env create -q -f /tmp/bioinformatics.yaml -p ${BIOINFORMATICS_DIR}
mamba clean -afy
