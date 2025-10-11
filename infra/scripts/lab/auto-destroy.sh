#!/usr/bin/env bash
set -euo pipefail
STACK_DIR="${1:-infra/live/lab/eks}"

pushd "$STACK_DIR"
terraform init -input=false
terraform apply -auto-approve -var-file=../../../env-profiles/terraform.tfvars.lab
echo "[lab] Sleeping 3600s before destroy..."
sleep 3600
terraform destroy -auto-approve -var-file=../../../env-profiles/terraform.tfvars.lab
popd
