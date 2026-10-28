#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
INFRA_DIR="$LAB_DIR/infra"

if [[ $# -ne 1 || ( "$1" != "mumbai" && "$1" != "singapore" ) ]]; then
  echo "Usage: $0 mumbai|singapore" >&2
  exit 2
fi

if ! command -v aws >/dev/null || ! command -v jq >/dev/null || ! command -v curl >/dev/null; then
  echo "This test requires the AWS CLI, jq, and curl." >&2
  exit 1
fi

if [[ "$(terraform -chdir="$INFRA_DIR" output -raw route53_enabled)" != "true" ]]; then
  echo "Enable Route 53 and set a hosted zone and app domain before testing failover." >&2
  exit 1
fi

if [[ "$1" == "mumbai" ]]; then
  failed_region="mumbai"
  healthy_region="singapore"
else
  failed_region="singapore"
  healthy_region="mumbai"
fi

asg_output="${failed_region}_asg_name"
url="$(terraform -chdir="$INFRA_DIR" output -raw application_url)"
asg_name="$(terraform -chdir="$INFRA_DIR" output -raw "$asg_output")"
sizes="$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "$asg_name" \
  --query 'AutoScalingGroups[0].[MinSize,DesiredCapacity,MaxSize]' \
  --output text)"

if [[ -z "$sizes" || "$sizes" == "None" ]]; then
  echo "Could not read the Auto Scaling group capacity for $asg_name." >&2
  exit 1
fi

read -r original_min original_desired original_max <<< "$sizes"
changed_capacity=false

restore_capacity() {
  if [[ "$changed_capacity" == "true" ]]; then
    echo "Restoring $failed_region Auto Scaling group capacity."
    aws autoscaling update-auto-scaling-group \
      --auto-scaling-group-name "$asg_name" \
      --min-size "$original_min" \
      --max-size "$original_max" \
      --desired-capacity "$original_desired"
  fi
}
trap restore_capacity EXIT

echo "This temporarily scales the $failed_region application to zero."
read -r -p "Type FAILOVER to continue: " confirmation
if [[ "$confirmation" != "FAILOVER" ]]; then
  echo "Failover test cancelled."
  exit 1
fi

changed_capacity=true
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name "$asg_name" \
  --min-size 0 \
  --desired-capacity 0

echo "Waiting up to 10 minutes for the application endpoint to serve $healthy_region."
for attempt in $(seq 1 60); do
  response="$(curl --silent --show-error --fail --max-time 10 "$url/api/events" 2>/dev/null || true)"
  served_region="$(printf '%s' "$response" | jq -r '.region // empty' 2>/dev/null || true)"
  if [[ "$served_region" == "$healthy_region" ]]; then
    echo "Failover verified: $url served by $served_region."
    exit 0
  fi
  echo "Attempt $attempt/60: waiting for DNS health checks (served: ${served_region:-no response})."
  sleep 10
done

echo "Timed out waiting for Route 53 failover to $healthy_region." >&2
exit 1
