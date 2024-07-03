import boto3
import sys

def assume_role(account_id):
    role_arn = f"arn:aws:iam::211125675990:role/StackSetAdminAccessRole"
    session_name = "DeleteDefaultVpcSession"

    sts_client = boto3.client("sts")
    assumed_role = sts_client.assume_role(
        RoleArn=role_arn, RoleSessionName=session_name
    )

    return boto3.Session(
        aws_access_key_id=assumed_role["Credentials"]["AccessKeyId"],
        aws_secret_access_key=assumed_role["Credentials"]["SecretAccessKey"],
        aws_session_token=assumed_role["Credentials"]["SessionToken"],
    )

def delete_default_vpc(account_id):
    session = assume_role(account_id)

    # Use the AWS SDK configured with the assumed role session
    ec2_client = session.client('ec2', region_name='us-east-1')

    response = ec2_client.describe_vpcs(
        Filters=[
            {
                'Name': 'isDefault',
                'Values': ['true']
            }
        ]
    )

    if not response['Vpcs']:
        print(f"No default VPC found for account {account_id}")
        return

    default_vpc_id = response['Vpcs'][0]['VpcId']

    # Get all dependent resources
    subnets = ec2_client.describe_subnets(Filters=[{'Name': 'vpc-id', 'Values': [default_vpc_id]}])['Subnets']
    igws = ec2_client.describe_internet_gateways(Filters=[{'Name': 'attachment.vpc-id', 'Values': [default_vpc_id]}])['InternetGateways']
    route_tables = ec2_client.describe_route_tables(Filters=[{'Name': 'vpc-id', 'Values': [default_vpc_id]}])['RouteTables']

    # Delete subnets
    for subnet in subnets:
        ec2_client.delete_subnet(SubnetId=subnet['SubnetId'])
        print(f"Deleted subnet: {subnet['SubnetId']}")

    # Detach and delete internet gateways
    for igw in igws:
        ec2_client.detach_internet_gateway(InternetGatewayId=igw['InternetGatewayId'], VpcId=default_vpc_id)
        ec2_client.delete_internet_gateway(InternetGatewayId=igw['InternetGatewayId'])
        print(f"Deleted internet gateway: {igw['InternetGatewayId']}")

    # Delete route tables (excluding the main route table)
    for rt in route_tables:
        for assoc in rt['Associations']:
            if not assoc['Main']:
                ec2_client.delete_route_table(RouteTableId=rt['RouteTableId'])
                print(f"Deleted route table: {rt['RouteTableId']}")

    # Finally, delete the default VPC
    ec2_client.delete_vpc(VpcId=default_vpc_id)
    print(f"Deleted default VPC: {default_vpc_id}")

if __name__ == "__main__":
    account_id = sys.argv[1]
    delete_default_vpc(account_id)