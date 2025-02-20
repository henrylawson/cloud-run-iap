#!/bin/bash
set -euo pipefail

terraform fmt
terraform init
terraform apply