import boto3
import json
from datetime import datetime as dt

def has_dev_tag(tags):
    for tag in tags:
        print(tag['Key']);
        print(tag['Value']);
        if tag['Key'] == 'Environment' and tag['Value'] == 'dev':
            return True
    return False

def lambda_handler(event, context):
    # Create boto3 clients
    ecs_client = boto3.client('ecs')
    ec2_client = boto3.client('ec2')
    s3_client = boto3.resource('s3')

    cluster_name = 'your-cluster-name-dev'
    service_names = [
        'your-service1',
        'your-service2',
        'your-service3',
        'your-service4'
    ]

    for service_name in service_names:
        ecs_client.update_service(
            cluster=cluster_name,
            service=service_name,
            desiredCount=0,
            forceNewDeployment=True
        )
    # Fetch the existing VPC Endpoints
    response = ec2_client.describe_vpc_endpoints()
    vpc_endpoints = response['VpcEndpoints']

    # Create a new list of dictionaries, but only with the fields we want to keep.
    vpc_endpoints_filtered = []
    for endpoint in vpc_endpoints:
        if has_dev_tag(endpoint.get('Tags', [])):
            filtered_endpoint = {k: v for k, v in endpoint.items() if not isinstance(v, dt)}
            vpc_endpoints_filtered.append(filtered_endpoint)

    # Save VPC Endpoints to s3_client
    bucket_name = 'your-project-dev-bucket'
    key = 'vpc_endpoints.json'
    s3_client.Object(bucket_name, key).put(Body=json.dumps(vpc_endpoints_filtered))

    # Delete VPC Endpoints (optional)
    for endpoint in vpc_endpoints_filtered:
        endpoint_id = endpoint['VpcEndpointId']
        ec2_client.delete_vpc_endpoints(VpcEndpointIds=[endpoint_id])
    return {
        'statusCode': 200,
        'body': json.dumps('VPC Endpoints deleted successfully!')
    }
