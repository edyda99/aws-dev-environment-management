import boto3
import json

def lambda_handler(event, context):
    # Hardcoded values - replace with your project specifics
    cluster_name = 'example-cluster'
    service_names = [
        'example-service-1',
        'example-service-2',
        'example-service-3',
        'example-service-4'
    ]
    bucket_name = 'example-bucket'
    key = 'vpc_endpoints.json'
    sg_id = 'sg-xxxxxxxx'

    # Create boto3 clients
    ecs_client = boto3.client('ecs')
    ec2_client = boto3.client('ec2')
    s3_client = boto3.resource('s3')

    # Update ECS services
    for service_name in service_names:
        ecs_client.update_service(
            cluster=cluster_name,
            service=service_name,
            desiredCount=1,
            forceNewDeployment=True
        )

    # Fetch saved VPC Endpoints from S3
    saved_vpc_endpoints = s3_client.Object(bucket_name, key).get()['Body'].read().decode('utf-8')
    saved_vpc_endpoints = json.loads(saved_vpc_endpoints)

    # Recreate VPC Endpoints
    for endpoint in saved_vpc_endpoints:
        service_name = endpoint['ServiceName']
        vpc_id = endpoint['VpcId']
        vpc_endpoint_type = endpoint.get('VpcEndpointType', 'Interface')

        # Include DNS settings
        private_dns_enabled = endpoint.get('PrivateDnsEnabled', True)

        # Tags (generic)
        truncated_service_name = service_name.split('.')[-1]
        common_tags = [{'Key': 'Environment', 'Value': 'example-environment'}]
        name_tag = [{'Key': 'Name', 'Value': truncated_service_name}]
        all_tags = common_tags + name_tag

        if vpc_endpoint_type == 'Interface':
            subnet_ids = endpoint['SubnetIds']
            ec2_client.create_vpc_endpoint(
                VpcId=vpc_id,
                ServiceName=service_name,
                SecurityGroupIds=[sg_id],
                VpcEndpointType='Interface',
                SubnetIds=subnet_ids,
                PrivateDnsEnabled=private_dns_enabled,
                TagSpecifications=[{'ResourceType': 'vpc-endpoint', 'Tags': all_tags}]
            )
        elif vpc_endpoint_type == 'Gateway':
            route_table_ids = endpoint['RouteTableIds']
            ec2_client.create_vpc_endpoint(
                VpcId=vpc_id,
                ServiceName=service_name,
                VpcEndpointType='Gateway',
                RouteTableIds=route_table_ids,
                TagSpecifications=[{'ResourceType': 'vpc-endpoint', 'Tags': all_tags}]
            )
    return {
        'statusCode': 200,
        'body': json.dumps('VPC Endpoints recreated successfully!')
    }
