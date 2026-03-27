import json
import os
import shutil
from os import path as osp
from textwrap import dedent
from typing import Optional

import pytest
from pytest_infrahouse import terraform_apply

from tests.conftest import (
    LOG,
    TERRAFORM_ROOT_DIR,
)

REGION = "us-east-1"


@pytest.mark.parametrize(
    "aws_provider_version", ["~> 5.56", "~> 6.0"], ids=["aws-5", "aws-6"]
)
def test_module(
    keep_after: bool, test_role_arn: Optional[str], aws_provider_version: str
) -> None:
    """Test the cost-alert module creates expected resources.

    :param keep_after: If True, do not destroy infrastructure after test.
    :param test_role_arn: AWS IAM role ARN to assume for testing.
    :param aws_provider_version: AWS provider version constraint to test against.
    """
    terraform_module_dir = osp.join(TERRAFORM_ROOT_DIR, "cost-alert")

    # Clean up stale Terraform state
    terraform_dir = osp.join(terraform_module_dir, ".terraform")
    if osp.isdir(terraform_dir):
        shutil.rmtree(terraform_dir)
    lock_file = osp.join(terraform_module_dir, ".terraform.lock.hcl")
    if osp.isfile(lock_file):
        os.remove(lock_file)

    with open(osp.join(terraform_module_dir, "terraform.tf"), "w") as fp:
        fp.write(dedent(f"""
                terraform {{
                  required_providers {{
                    aws = {{
                      source  = "hashicorp/aws"
                      version = "{aws_provider_version}"
                    }}
                  }}
                }}
                """))

    with open(osp.join(terraform_module_dir, "terraform.tfvars"), "w") as fp:
        fp.write(dedent(f"""
                region = "{REGION}"
                """))
        if test_role_arn:
            fp.write(dedent(f"""
                    role_arn = "{test_role_arn}"
                    """))

    with terraform_apply(
        terraform_module_dir,
        destroy_after=not keep_after,
        json_output=True,
    ) as tf_output:
        LOG.info(json.dumps(tf_output, indent=4))

        assert "sns_topic_arn" in tf_output
        assert "cloudwatch_alarm_arn" in tf_output
        assert tf_output["sns_topic_arn"]["value"].startswith("arn:aws:sns:")
        assert tf_output["cloudwatch_alarm_arn"]["value"].startswith("arn:aws:cloudwatch:")
