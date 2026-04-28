#! /bin/bash

set -euo pipefail

# mamba env create -q -n molecularecology -f /tmp/molecularecology.yaml
mamba env create \
  --name molecularecology \
  --file https://raw.githubusercontent.com/qiime2/distributions/refs/heads/dev/2026.4/qiime2/released/rachis-qiime2-linux-64-conda.yml
mamba clean -afy
