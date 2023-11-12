# AWS Development Environment Management

This repository hosts a Python script designed to be deployed as an AWS Lambda function.<br>
This will be one of many articles where we will build up the puzzle towards our goal which is to make our dev environment functional only during working hours with the flexibility to turn it on with simple strategies.<br>

Goals tackled will be added to the README with each commit.<br>
- The script interacts with AWS Elastic Container Service (ECS), Elastic Compute Cloud (EC2), and Simple Storage Service (S3) to manage, save, and optionally delete VPC endpoints in a development environment. The goal is to automate the management of VPC endpoints, making the development process smoother and more efficient.<br>
- Added a Lambda function to restart the AWS services on weekday mornings. This helps to ensure that the environment is only active during necessary business hours, reducing unnecessary resource usage and aligning with eco-friendly practices. The function not only starts ECS services but also recreates VPC endpoints using configurations saved in S3, making our environment ready for a new day's work.<br>
- Integrated AWS CloudWatch to fully automate the process. CloudWatch Events are set up to trigger the Lambda functions based on a defined schedule, aligning our resource availability with business hours without manual intervention.<br>
