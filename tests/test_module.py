import json
from os import path as osp
from textwrap import dedent

from infrahouse_toolkit.terraform import terraform_apply

from tests.conftest import (
    LOG,
    TRACE_TERRAFORM,
    REGION,
    TERRAFORM_ROOT_DIR,
)


def test_module(keep_after, test_role_arn):

    # Create ECS with httpd container
    terraform_module_dir = osp.join(TERRAFORM_ROOT_DIR, "cost-alert")
    with open(osp.join(terraform_module_dir, "terraform.tfvars"), "w") as fp:
        fp.write(
            dedent(
                f"""
                role_arn      = "{test_role_arn}"
                region        = "{REGION}"
                """
            )
        )

    with terraform_apply(
        terraform_module_dir,
        destroy_after=not keep_after,
        json_output=True,
        enable_trace=TRACE_TERRAFORM,
    ) as tf_output:
        LOG.info(json.dumps(tf_output, indent=4))
