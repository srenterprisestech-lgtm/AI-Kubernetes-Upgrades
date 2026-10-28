#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
INFRA_DIR="$LAB_DIR/infra"

if [[ -z "${TF_STATE_BUCKET:-}" || -z "${TF_STATE_REGION:-}" ]]; then
  echo "Set TF_STATE_BUCKET and TF_STATE_REGION to the existing Terraform state bucket." >&2
  exit 1
fi

terraform -chdir="$INFRA_DIR" init -input=false \
  -backend-config="bucket=$TF_STATE_BUCKET" \
  -backend-config="region=$TF_STATE_REGION"

plan_file="$(mktemp)"
trap 'rm -f "$plan_file"' EXIT

terraform -chdir="$INFRA_DIR" plan -destroy -input=false -out="$plan_file"
terraform -chdir="$INFRA_DIR" show -no-color "$plan_file"
echo "This permanently deletes the resources in the plan above."
read -r -p "Type DESTROY to continue: " confirmation
if [[ "$confirmation" != "DESTROY" ]]; then
  echo "Destroy cancelled."
  exit 1
fi

terraform -chdir="$INFRA_DIR" apply -input=false "$plan_file"
