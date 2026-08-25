#! /bin/bash

set -euo pipefail

mamba env create -y -q --file="/tmp/bioinformatics.yaml"
mamba clean -afy
