# taskSolution
This Terraform code provisions an EC2 instance in a newly created VPC with a new subnet and security group. It also installs and configures Elasticsearch on the instance and tests its API using a null_resource.

To achieve the desired outcome, I started by specifying the AWS provider with the region and access credentials. Then, I created a new VPC with a specified CIDR block using the aws_vpc resource. Next, I created a new subnet in the VPC using the aws_subnet resource and specify the VPC ID and CIDR block.

After that, I created a new security group using the aws_security_group resource, which opens ports 22 and 9200 for SSH and Elasticsearch traffic, respectively. I also specified the VPC ID and name prefix.

Then I launched an EC2 instance using the aws_instance resource and specify the AMI, instance type, key name, subnet ID, and security group ID. I also add tags to identify the instance and configure SSH access using a connection block and a provisioner block that installs and configures Elasticsearch.

Finally, I created a null_resource that depends on the EC2 instance and uses a local-exec provisioner to test the Elasticsearch API by sending an HTTP GET request to port 9200.

Resources:

AWS documentation on Terraform: https://aws.amazon.com/getting-started/hands-on/deploy-app-terraform/
Terraform documentation: https://www.terraform.io/docs/providers/aws/index.html
Time spent:

I spent around 3 hours reviewing the code and writing the solution.
