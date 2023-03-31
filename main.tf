provider "aws" {
  region     = "demo_region"
  access_key = "demo_access_key"
  secret_key = "demo_secret_key"
}


# Create a new VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create a new subnet
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
}

# Create a new security group
resource "aws_security_group" "my_security_group" {
  name_prefix = "elasticsearch"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 instance
resource "aws_instance" "my_instance" {
  ami                    = "demoAmi"
  instance_type          = "t2.micro"
  key_name               = "demoKey"
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  subnet_id              = aws_subnet.my_subnet.id
  tags = {
    Name = "elasticsearch-instance"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/demoKey.pem")
    timeout     = "2m"
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y openjdk-8-jre-headless",
      "wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -",
      "echo 'deb https://artifacts.elastic.co/packages/7.x/apt stable main' | sudo tee /etc/apt/sources.list.d/elastic-7.x.list",
      "sudo apt-get update",
      "sudo apt-get install -y elasticsearch",
      "sudo sed -i 's/#cluster.name: my-application/cluster.name: my-elasticsearch-cluster/g' /etc/elasticsearch/elasticsearch.yml",
      "sudo sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/g' /etc/elasticsearch/elasticsearch.yml",
      "sudo sed -i 's/#http.port: 9200/http.port: 9200/g' /etc/elasticsearch/elasticsearch.yml",
      "sudo sed -i 's/#discovery.seed_hosts: {\"host1\", \"host2\"}/discovery.seed_hosts: [\"${aws_instance.my_instance.private_ip}\"]}/g' /etc/elasticsearch/elasticsearch.yml",
      "sudo systemctl enable elasticsearch",
      "sudo systemctl start elasticsearch"
    ]
  }
}

# Create a null_resource to test the Elasticsearch API
resource "null_resource" "provisioner" {
  depends_on = [aws_instance.my_instance]

  provisioner "local-exec" {
    command = "sleep 60 && curl -X GET http://${aws_instance.my_instance.public_ip}:9200"
  }
}
