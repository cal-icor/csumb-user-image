#! /bin/bash

set -euo pipefail

mamba env create -q -f /tmp/bioinformatics.yaml
mamba clean -afy
