import boto3
import pytest
import logging

from infrahouse_toolkit.logging import setup_logging

TEST_ROLE_ARN = "arn:aws:iam::303467602807:role/ecs-tester"
DEFAULT_PROGRESS_INTERVAL = 10
TRACE_TERRAFORM = False
UBUNTU_CODENAME = "jammy"

LOG = logging.getLogger()
REGION = "us-east-1"
TERRAFORM_ROOT_DIR = "test_data"

setup_logging(LOG, debug=True)


def pytest_addoption(parser):
    parser.addoption(
        "--keep-after",
        action="store_true",
        default=False,
        help="If specified, don't destroy resources.",
    )
    parser.addoption(
        "--test-role-arn",
        action="store",
        default=TEST_ROLE_ARN,
        help=f"AWS IAM role ARN that will create resources. Default, {TEST_ROLE_ARN}",
    )

@pytest.fixture(scope="session")
def keep_after(request):
    return request.config.getoption("--keep-after")


@pytest.fixture(scope="session")
def test_role_arn(request):
    return request.config.getoption("--test-role-arn")

@pytest.fixture(scope="session")
def aws_iam_role():
    sts = boto3.client("sts")
    return sts.assume_role(
        RoleArn=TEST_ROLE_ARN, RoleSessionName=TEST_ROLE_ARN.split("/")[1]
    )


@pytest.fixture(scope="session")
def boto3_session(aws_iam_role):
    return boto3.Session(
        aws_access_key_id=aws_iam_role["Credentials"]["AccessKeyId"],
        aws_secret_access_key=aws_iam_role["Credentials"]["SecretAccessKey"],
        aws_session_token=aws_iam_role["Credentials"]["SessionToken"],
    )


@pytest.fixture(scope="session")
def ec2_client(boto3_session):
    return boto3_session.client("ec2", region_name=REGION)


@pytest.fixture(scope="session")
def ec2_client_map(ec2_client, boto3_session):
    regions = [reg["RegionName"] for reg in ec2_client.describe_regions()["Regions"]]
    ec2_map = {reg: boto3_session.client("ec2", region_name=reg) for reg in regions}

    return ec2_map


@pytest.fixture()
def route53_client(boto3_session):
    return boto3_session.client("route53", region_name=REGION)


@pytest.fixture()
def elbv2_client(boto3_session):
    return boto3_session.client("elbv2", region_name=REGION)
