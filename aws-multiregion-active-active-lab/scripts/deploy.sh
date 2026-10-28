#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
INFRA_DIR="$LAB_DIR/infra"

if [[ -z "${TF_STATE_BUCKET:-}" || -z "${TF_STATE_REGION:-}" ]]; then
  echo "Set TF_STATE_BUCKET and TF_STATE_REGION to an existing private S3 state bucket." >&2
  exit 1
fi

terraform -chdir="$INFRA_DIR" init -input=false \
  -backend-config="bucket=$TF_STATE_BUCKET" \
  -backend-config="region=$TF_STATE_REGION"
terraform -chdir="$INFRA_DIR" validate

plan_file="$(mktemp)"
trap 'rm -f "$plan_file"' EXIT

terraform -chdir="$INFRA_DIR" plan -input=false -out="$plan_file"
terraform -chdir="$INFRA_DIR" show -no-color "$plan_file"
read -r -p "Apply the plan shown above? Type yes to continue: " confirmation
if [[ "$confirmation" != "yes" ]]; then
  echo "Deployment cancelled."
  exit 1
fi

terraform -chdir="$INFRA_DIR" apply -input=false "$plan_file"
