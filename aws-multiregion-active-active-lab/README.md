# AWS Multi-Region Active-Active Failover Lab

Deploy a small web application to Mumbai (`ap-south-1`) and Singapore
(`ap-southeast-1`), backed by a DynamoDB global table. Optional Route 53 latency
records with regional health checks provide a shared endpoint and DNS failover.

> **Cost and security:** This lab creates public Application Load Balancers,
> EC2 instances, a DynamoDB global table, and (when enabled) Route 53 health
> checks. These resources incur charges while they exist. Review AWS pricing,
> use a dedicated lab account, and run `scripts/destroy.sh` when finished. The
> demo serves HTTP and places instances in public subnets with no inbound access
> except through their ALB. It is an educational example, not a production
> reference architecture.

## Architecture

```text
                         Route 53 latency records (optional)
                           + health-check failover
                              /             \
                    Mumbai ALB             Singapore ALB
                        |                        |
                 EC2 app instances        EC2 app instances
                        \                        /
                         DynamoDB global table
```

Each region has its own VPC, public subnets across two availability zones,
internet gateway, ALB, and Auto Scaling group. The application writes submitted
messages to the local DynamoDB replica. Global-table replication is
asynchronous, so a write may not immediately appear in the other region.

Without Route 53 configured, use the two regional ALB URLs in Terraform outputs
to test each region independently. To exercise DNS failover, configure an
existing public hosted zone and an application hostname.

## Prerequisites

- An AWS account with permissions to create the resources in this lab.
- Terraform 1.10 or later, Bash (Git Bash or WSL on Windows), AWS CLI v2,
  `curl`, and `jq`.
- For Route 53: an existing public hosted zone and a domain/subdomain delegated
  to it.
- For GitHub Actions: an AWS IAM role trusted through GitHub OIDC, a durable
  S3 Terraform state bucket with versioning and encryption enabled, and the
  repository variables listed under [GitHub Actions](#github-actions).

Do not commit AWS credentials, state files, or secret values. Terraform state
can contain sensitive information; keep the state bucket private and restrict
access to it.

## Configure

1. Copy `infra/terraform.tfvars` to `infra/lab.auto.tfvars` if you want to keep
   your local settings separate. Edit the values for your lab.
2. To enable the global DNS endpoint, set `enable_route53 = true`, then set
   `route53_zone_id` to your public hosted-zone ID and `app_domain` to a name
   within that zone (for example, `active-active.example.com`).
3. Configure the S3 state backend environment variables:

   ```bash
   export TF_STATE_BUCKET="your-private-versioned-state-bucket"
   export TF_STATE_REGION="ap-south-1"
   ```

   PowerShell:

   ```powershell
   $env:TF_STATE_BUCKET = "your-private-versioned-state-bucket"
   $env:TF_STATE_REGION = "ap-south-1"
   ```

   The bucket must already exist. The Terraform backend uses S3 native state
   locking; it does not create or configure the bucket.

## Deploy

From the repository root:

```bash
bash aws-multiregion-active-active-lab/scripts/deploy.sh
```

The script initializes the S3 backend, validates the configuration, shows the
plan, and asks for confirmation before applying. Review every planned resource
before approving it.

Get the application endpoints:

```bash
terraform -chdir=aws-multiregion-active-active-lab/infra output
```

Open the Route 53 application URL if enabled, or test each regional ALB URL:

```bash
curl "$(terraform -chdir=aws-multiregion-active-active-lab/infra output -raw mumbai_url)/api/events"
curl "$(terraform -chdir=aws-multiregion-active-active-lab/infra output -raw singapore_url)/api/events"
```

Submit an event to either region:

```bash
curl -X POST \
  -H 'Content-Type: application/json' \
  -d '{"message":"hello from Mumbai"}' \
  "$(terraform -chdir=aws-multiregion-active-active-lab/infra output -raw mumbai_url)/api/events"
```

Refresh `/api/events` through each region to observe global-table replication.
Replication is eventually consistent; allow time for changes to propagate.

## Test regional failover

Failover testing scales one region's application to zero temporarily. It needs
Route 53 enabled and `jq` installed. Run it from the repository root:

```bash
bash aws-multiregion-active-active-lab/scripts/failover-test.sh mumbai
```

The script asks for confirmation, waits for the application endpoint to serve
traffic from the other region, and restores the original Auto Scaling group
capacity on exit. Route 53 health checks and DNS caching mean failover is not
instantaneous. You can also pass `singapore` to test the other direction.

## Destroy

Review the destroy plan and explicitly confirm before deleting lab resources:

```bash
bash aws-multiregion-active-active-lab/scripts/destroy.sh
```

The Terraform state bucket is not managed by this lab and is not deleted.

## GitHub Actions

- **PR check** runs Terraform formatting and validation without AWS credentials.
- **Deploy** is manual (`workflow_dispatch`) and applies the reviewed lab
  configuration using GitHub OIDC.
- **Destroy** is manual and requires the exact confirmation string `DESTROY`.

Configure these repository variables before using deploy/destroy:

| Variable | Purpose |
| --- | --- |
| `AWS_ROLE_ARN` | IAM role ARN trusted for this repository's GitHub OIDC identity |
| `AWS_REGION` | AWS region used for the S3 state backend, for example `ap-south-1` |
| `TF_STATE_BUCKET` | Existing private, versioned S3 bucket for Terraform state |

The workflow uses `AWS_REGION` for backend initialization and AWS
authentication. Set it to the region where the state bucket resides. Configure
an environment protection rule for the `lab` environment if deployments should
require approval.

## Cleanup and learning goals

- Compare the two regional ALB responses before and after a health-check
  failure.
- Observe the Route 53 health-check state and DNS response during failover.
- Compare a write in one region with reads from the other and discuss eventual
  consistency.
- Consider what changes are needed for HTTPS, private subnets, observability,
  backups, application secrets, and a production-grade recovery objective.
