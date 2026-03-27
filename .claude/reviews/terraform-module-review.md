# Terraform Module Review: terraform-aws-cost-alert

**Review Date:** 2026-03-27
**Review Type:** Full codebase review

## Summary

This is a small, focused Terraform module that creates a CloudWatch metric alarm for AWS daily cost
monitoring with SNS email notifications. The core functionality is sound and well-scoped. However,
there are several gaps relative to the InfraHouse coding standard, particularly around README
structure, variable validation, tagging, documentation pages, and missing repository files. The
testing approach is modern and correct (using pytest-infrahouse fixtures), though the test could
benefit from actual assertions. Security posture is appropriate for the module's scope -- there are
no IAM policies, no secrets, and no overly permissive configurations.

## Findings

### Critical

1. **SNS topic lacks encryption at rest**
   - **File:** `main.tf` line 34-36
   - The `aws_sns_topic.cost_notifications` resource does not set `kms_master_key_id`. Per the
     coding standard, encryption at rest should be enabled by default for all resources. SNS
     supports server-side encryption with AWS-managed keys (`alias/aws/sns`).
   - **Fix:** Add `kms_master_key_id = "alias/aws/sns"` to the SNS topic resource.

2. **No `outputs.tf` file in the root module**
   - **File:** Missing
   - The coding standard requires all modules to have at minimum `main.tf`, `variables.tf`, and
     `outputs.tf`. The `outputs.tf` file does not exist. Even if there are no outputs currently,
     the file should exist (can be empty or with a comment). Furthermore, the SNS topic ARN and
     CloudWatch alarm ARN are reasonable outputs that other modules might need.
   - **Fix:** Create `outputs.tf` with at least the SNS topic ARN and alarm ARN as outputs.

### Important

3. **README.md is missing required structure and badges**
   - **File:** `README.md`
   - The coding standard requires specific badges (Contact, Docs, Registry, Release, AWS Service,
     Security, License) and specific sections (Features, Quick Start, Documentation, Examples,
     Contributing, License). The current README only has a brief description followed by the
     terraform-docs auto-generated content -- none of the required badges or sections are present.
   - **Fix:** Add all required badges and sections above the `<!-- BEGIN_TF_DOCS -->` marker.

4. **Missing variable validation blocks**
   - **File:** `variables.tf`
   - The coding standard states validation should catch definitely wrong input values:
     - `cost_threshold` should validate it is a positive number (`> 0`).
     - `notification_email` should have a basic email format validation (regex).
     - `period_hours` should validate it is a positive number and ideally that it evenly divides
       24 (since `evaluation_periods = 24 / var.period_hours` would produce a non-integer
       otherwise). Valid values would be 1, 2, 3, 4, 6, 8, 12, 24.
   - **Fix:** Add validation blocks to these variables.

5. **`period_hours` description is inaccurate**
   - **File:** `variables.tf` line 18-19
   - The description says "The alert sums up cost per this period" but the actual metric expression
     in `main.tf` is `RATE(m1) * 3600 * 24`, which calculates the *estimated daily cost* (rate
     extrapolated to 24 hours), not the cost per period. The period only affects the evaluation
     granularity, not the threshold comparison unit.
   - **Fix:** Update the description to accurately describe what the variable controls: the
     evaluation granularity/window, not the cost aggregation period.

6. **`period_hours` line exceeds 120 characters**
   - **File:** `variables.tf` line 18
   - The description string on this line is 139 characters, exceeding the 120-character maximum.
     The coding standard recommends using HEREDOC for long descriptions.
   - **Fix:** Convert to HEREDOC format.

7. **No tags on any resources**
   - **File:** `main.tf`
   - The coding standard requires resource provenance tags (`created_by_module`) and recommends
     tagging resources. Neither the CloudWatch alarm nor the SNS topic has any tags.
   - **Fix:** Add at minimum a `tags` block with `created_by_module = "infrahouse/cost-alert/aws"`
     to both the CloudWatch alarm and SNS topic.

8. **Missing `environment` variable**
   - **File:** `variables.tf`
   - The coding standard says modules should require an `environment` tag from the user (no
     default). This module has no `environment` variable and does not tag resources with the
     environment.
   - **Fix:** Add a required `environment` variable and include it in resource tags.

9. **Module name in test data uses hyphen instead of underscore**
   - **File:** `test_data/cost-alert/main.tf` line 1
   - The module is named `cost-alert` (with a hyphen). The coding standard requires snake_case
     everywhere: "Use underscores (`_`), not dashes (`-`)".
   - **Fix:** Rename to `module "cost_alert"`.

10. **Missing `CHANGELOG.md`**
    - The coding standard lists `CHANGELOG.md` as a "must have" repository file. It does not exist
      in the repository.
    - **Fix:** Generate with `git-cliff` and commit.

11. **Missing `examples/` directory**
    - The coding standard lists `examples/` as a "must have" repository file. No examples directory
      exists.
    - **Fix:** Create at least one working example in `examples/basic/`.

12. **Missing required GitHub Pages documentation**
    - **File:** `docs/`
    - The coding standard requires `docs/getting-started.md` and `docs/configuration.md`. Only
      `docs/index.md` exists, and its content is a single line that is less informative than the
      README.
    - **Fix:** Create the required documentation pages.

13. **`install-hooks` does not install `commit-msg` hook**
    - **File:** `Makefile` lines 22-25
    - The coding standard requires `install-hooks` to run `pre-commit install` and
      `pre-commit install --hook-type commit-msg`. The current implementation uses a manual
      symlink approach for pre-commit only and does not install the commit-msg hook. There is a
      `hooks/commit-msg` file in the repo but it is not being symlinked.
    - **Fix:** Add symlink for `hooks/commit-msg` to `.git/hooks/commit-msg`, or switch to the
      `pre-commit` framework as the standard recommends.

### Minor

14. **Test has no meaningful assertions**
    - **File:** `tests/test_module.py` line 68
    - The test applies infrastructure and logs the output, but does not assert anything about the
      created resources. At minimum, it should verify that the CloudWatch alarm and SNS topic were
      created and have expected properties.
    - **Fix:** Add assertions that check the terraform output or query AWS resources to verify
      correct configuration.

15. **Test function lacks type hints**
    - **File:** `tests/test_module.py` line 19
    - The coding standard requires type hints for all functions. `test_module()` has no type hints
      on its parameters or return value.
    - **Fix:** Add type hints: `def test_module(keep_after: bool, test_role_arn: str,
      aws_provider_version: str) -> None:`.

16. **Test function and conftest lack docstrings**
    - **File:** `tests/test_module.py`, `tests/conftest.py`
    - The coding standard requires RST docstrings for all functions. The `test_module` function
      has no docstring. While `conftest.py` has a module-level docstring, it is not RST format.
    - **Fix:** Add RST-format docstrings.

17. **`docs/index.md` is minimal**
    - **File:** `docs/index.md`
    - Contains only a title and one sentence. Should include overview, features, and quick start
      information per the coding standard.
    - **Fix:** Expand with meaningful content.

18. **Unused import in test file**
    - **File:** `tests/test_module.py` line 1
    - `json` is imported and used only for logging (`json.dumps`). This is not a bug but the
      import of `json` solely for debug logging is marginally unnecessary if the test had proper
      assertions that did not need to dump the full output.
    - **Severity:** Very minor, no action strictly needed.

19. **Missing `.bumpversion.cfg`**
    - The Makefile's `do_release` function reads from `.bumpversion.cfg` but this file does not
      exist in the repository. The release targets would fail.
    - **Fix:** Create `.bumpversion.cfg` with the current version.


### Positive

1. **Clean, focused module design** -- The module does exactly one thing well: monitors AWS daily
   cost and sends email alerts. Three resources, no unnecessary complexity.

2. **Correct metric math** -- The `RATE(m1) * 3600 * 24` expression correctly computes the
   estimated daily cost rate from the cumulative `EstimatedCharges` metric.

3. **Multi-provider-version testing** -- The test is parametrized with both `~> 5.56` and `~> 6.0`
   AWS provider versions, ensuring compatibility across major versions.

4. **Modern test infrastructure** -- Uses `pytest-infrahouse` with `terraform_apply` fixture,
   follows the pattern of writing `terraform.tf` and `terraform.tfvars` dynamically, and properly
   cleans up `.terraform` state between parametrized runs.

5. **Proper `created_by` tag in test provider** -- The test data provider configuration includes
   `created_by = "infrahouse/terraform-aws-cost-alert"` in default_tags, as required.

6. **Good `.gitignore` coverage** -- Properly ignores terraform state, lock files, pytest cache,
   IDE files, test output logs, and generated `terraform.tfvars`/`terraform.tf` in test data.

7. **Conventional Commits and release automation** -- The Makefile includes a well-implemented
   `do_release` function with safety checks (branch validation, tool presence checks, user
   confirmation).

8. **Pre-commit hook** -- Managed by github-control, checks terraform formatting, terraform-docs
   generation, and trailing newlines.

9. **CI/CD pipeline** -- Complete set of workflows for CD (module publishing), PR review, security
   scanning (checkov), documentation deployment, and release automation.

10. **Apache 2.0 License** -- Correct license choice per coding standard, with proper copyright
    notice.

11. **Dependencies pinned correctly** -- `requirements.txt` uses `~=` syntax as required by the
    coding standard for Python dependencies.

12. **Renovate configured** -- Dependency management is automated with Renovate, with
    github-control-managed workflows properly excluded from auto-updates.
