import boto3
import sys

def delete_default_vpc(account_id):
    session = boto3.Session(profile_name='default')
    sts_client = session.client('sts')
    response = sts_client.assume_role(
        RoleArn=f'arn:aws:iam::{account_id}:role/OrganizationAccountAccessRole',
        RoleSessionName='DeleteDefaultVPCSession'
    )
    credentials = response['Credentials']

    ec2_client = boto3.client(
        'ec2',
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken'],
        region_name='us-east-1'
    )

    response = ec2_client.describe_vpcs(
        Filters=[
            {
                'Name': 'isDefault',
                'Values': ['true']
            }
        ]
    )

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
        if not rt['Associations'][0]['Main']:
            ec2_client.delete_route_table(RouteTableId=rt['RouteTableId'])
            print(f"Deleted route table: {rt['RouteTableId']}")

    # Finally, delete the default VPC
    ec2_client.delete_vpc(VpcId=default_vpc_id)
    print(f"Deleted default VPC: {default_vpc_id}")

if __name__ == "__main__":
    account_id = sys.argv[1]
    delete_default_vpc(account_id)
