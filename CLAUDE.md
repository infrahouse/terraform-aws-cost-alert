# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## First Steps

**Your first tool call in this repository MUST be reading
.claude/CODING_STANDARD.md. Do not read any other files, search, or take any
actions until you have read it.** This contains InfraHouse's comprehensive
coding standards for Terraform, Python, and general formatting rules.

## What This Module Does

Terraform module that creates a CloudWatch alarm to monitor AWS daily cost
and sends notifications to an email via SNS. It must be deployed in
**us-east-1** (billing metrics only exist there) and requires billing alerts
to be
[enabled explicitly](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/monitor_estimated_charges_with_cloudwatch.html#turning_on_billing_metrics).

## Build and Development Commands

```bash
make bootstrap        # Install Python deps (pip + requirements.txt)
make test             # Run pytest integration tests (creates real AWS infra)
make format           # terraform fmt -recursive
make fmt              # Alias for format
make lint             # black --check tests && terraform fmt -check
make clean            # Remove .pytest_cache and .terraform dirs
make install-hooks    # Symlink pre-commit hook from hooks/
```

Run a single test:
```bash
pytest -xvvs tests/test_module.py::test_module
```

Keep infrastructure after tests (for debugging):
```bash
pytest -xvvs tests/ --keep-after
```

Override the test IAM role:
```bash
pytest -xvvs tests/ --test-role-arn "arn:aws:iam::ACCOUNT:role/ROLE"
```

## Architecture

The module is simple: three resources in `main.tf` (CloudWatch metric alarm,
SNS topic, SNS email subscription). No submodules or outputs.

### Testing Pattern

Tests use `pytest-infrahouse` and `infrahouse-core` (pinned in
`requirements.txt`). The test creates real AWS infrastructure:

1. `tests/conftest.py` assumes an IAM role via STS, creates a boto3
   session, and provides pytest fixtures
2. `tests/test_module.py` writes `terraform.tfvars` into
   `test_data/cost-alert/`, then runs `terraform_apply` from
   `infrahouse_toolkit.terraform`
3. `test_data/cost-alert/` is the test root module that calls
   `source = "../../"` to test the module
4. Test region is hardcoded to `us-east-1` (required for billing metrics)
5. Default test role: `arn:aws:iam::303467602807:role/ecs-tester`

### Pre-commit Hook

The `hooks/pre-commit` script (managed by github-control) checks:
- `terraform fmt` formatting
- `terraform-docs` README generation
- Trailing newlines on all files

### CI/CD

- **terraform-CD.yml**: On tag push, publishes module to
  `registry.infrahouse.com` via `ih-registry upload`
- **terraform-review.yml**: PR review workflow
- **checkov.yml**: Security scanning
- **release.yml**: Auto-creates GitHub Releases from tags
- **docs.yml**: Deploys MkDocs documentation to GitHub Pages

### Key Conventions

- README.md is auto-generated between `<!-- BEGIN_TF_DOCS -->` markers by
  terraform-docs (config in `.terraform-docs.yml`)
- Several repo files are managed externally by the `github-control`
  repository -- do not edit: `.terraform-docs.yml`, `hooks/pre-commit`,
  `mkdocs.yml`, `cliff.toml`, CI workflow files
- Python formatting: `black`
- Commit messages follow
  [Conventional Commits](https://www.conventionalcommits.org/)
- Max line length: 120 characters (all files)
- All files must end with a newline
