terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  access_key = "<<>>"
  secret_key = "<<>>"
  region     = "ap-south-1"
}

/*ata "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}*/

resource "aws_s3_bucket" "hrkumaran_s3_bucket_myapp" {
  bucket = "hrkumaran-myapp-prod"
  #acl = "private"
}

resource "aws_s3_bucket_object" "s3_bucket_object_myapp" {
  bucket = aws_s3_bucket.hrkumaran_s3_bucket_myapp.id
  key = "beanstalk/myapp"
  source = "target/springboot-k8s-demo.jar"
}

resource "aws_elastic_beanstalk_application" "beanstalk_myapp" {
  name        = "myapp"
  description = "The description of my application"
}

resource "aws_elastic_beanstalk_application_version" "beanstalk_myapp_version" {
  application = aws_elastic_beanstalk_application.beanstalk_myapp.name
  bucket      = aws_s3_bucket.hrkumaran_s3_bucket_myapp.id
  key         = aws_s3_bucket_object.s3_bucket_object_myapp.id
  name        = "myapp-1.0.0"
}

resource "aws_elastic_beanstalk_environment" "beanstalk_myapp_env" {
  name                = "hrkumaran-myapp-prod"
  application         = aws_elastic_beanstalk_application.beanstalk_myapp.name
  solution_stack_name = "64bit Amazon Linux 2 v3.2.16 running Corretto 11"
  version_label       = aws_elastic_beanstalk_application_version.beanstalk_myapp_version.name

  setting {
    name      = "SERVER_PORT"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "5000"
  }

  setting {
    namespace = "aws:ec2:instances"
    name      = "InstanceTypes"
    value     = "t2.micro"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }
}




