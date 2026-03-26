#! /bin/bash

set -euo pipefail

mamba env create -q -n molecularecology -f /tmp/molecularecology.yaml
mamba clean -afy
