#! /bin/bash

set -euo pipefail

mamba env create -y -q -f /tmp/bioinformatics.yaml
mamba clean -afy
