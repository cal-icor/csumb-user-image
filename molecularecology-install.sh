#! /bin/bash

set -euo pipefail

ENV_DEF="https://raw.githubusercontent.com/qiime2/distributions/refs/heads/dev/2026.4/qiime2/released/rachis-qiime2-linux-64-conda.yml"
curl --silent --location --fail ${ENV_DEF} > /tmp/$(basename ${ENV_DEF})
ENV_FILE="/tmp/$(basename ${ENV_DEF})"
sed -i '1iname: molecularecology' ${ENV_FILE}
mamba env create -y -q --file=${ENV_FILE}
mamba clean -afy
