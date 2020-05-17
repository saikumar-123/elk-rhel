provider "aws" {
  region  = "us-east-1"
 # access_key = "${var.aws_access_key}"
 # secret_key = "${var.aws_secret_key}"
  shared_credentials_file = "/home/sai.d/.aws/credentials"
  profile                 = "default"

}
/*
data "template_file" "elastic"{
  template = "${file("elastic-vars.json.tpl")}"
  vars = {
	server_ip = "{aws_instance.ansible-elastic.private_ip}"
  }
}
*/
resource "aws_instance" "ansible-elastic" {
	ami = "${var.ami_id}"
	instance_type = "${var.elastic_instance_type}"
        key_name = "${var.key_name}"
	subnet_id = "subnet-0de41be2xxxxxxxx"
	iam_instance_profile = "ec2_role_for_maagc"
	root_block_device {
            volume_type= "standard"
            volume_size = "30"
          }
	tags = { Name = "Enabling-elasticsearch" }
	security_groups = "${compact(split(",", var.security_groups["security_groups"]))}"
	
        provisioner "local-exec" {
           command = " echo 'elastic_server_ip: ${aws_instance.ansible-elastic.private_ip}' > elk-vars.yml"
        }
	provisioner "local-exec" {
          command = "ansible-playbook --private-key=/home/sai.d/poc.pem -u ec2-user -i ${aws_instance.ansible-elastic.private_ip}, playbooks/elastic.yml --extra-vars '@elk-vars.yml'"
	}
}

resource "aws_instance" "ansible-kibana" {
        ami = "${var.ami_id}"
        instance_type = "${var.kibana_instance_type}"
        key_name = "${var.key_name}"
        subnet_id = "subnet-0de41bxxxxxxxxxx"
        iam_instance_profile = "ec2_role_for_maagc"
        root_block_device {
            volume_type= "standard"
            volume_size = "30"
          }
        tags = { Name = "Enabling-kibana" }
        security_groups = "${compact(split(",", var.security_groups["security_groups"]))}"

        provisioner "local-exec" {
           command = " echo 'kibana_server_ip: ${aws_instance.ansible-kibana.private_ip}' > elk-vars.yml"
        }

        provisioner "local-exec" {
          command = "ansible-playbook --private-key=/home/sai.d/poc.pem -u ec2-user -i ${aws_instance.ansible-logstash.private_ip}, playbooks/kibana.yml --extra-vars '@elk-vars.yml'"
        }
        depends_on = [aws_instance.ansible-elastic]
}

resource "aws_instance" "ansible-beats" {
        ami = "${var.ami_id}"
        instance_type = "${var.beats_instance_type}"
        key_name = "${var.key_name}"
        subnet_id = "subnet-0de4xxxxxxxxxxxxxxxxxx"
        iam_instance_profile = "ec2_role_for_maagc"
        root_block_device {
            volume_type= "standard"
            volume_size = "30"
          }
        tags = { Name = "Enabling-beats" }
        security_groups = "${compact(split(",", var.security_groups["security_groups"]))}"

        provisioner "local-exec" {
           command = " echo 'beats_server_ip: ${aws_instance.ansible-beats.private_ip}' > elk-vars.yml"
        }

        provisioner "local-exec" {
          command = "ansible-playbook --private-key=/home/sai.d/poc.pem -u ec2-user -i ${aws_instance.ansible-beats.private_ip}, playbooks/beats.yml --extra-vars '@elk-vars.yml'"
        }
        depends_on = [aws_instance.ansible-elastic,aws_instance.ansible-kibana]
}


resource "aws_instance" "ansible-logstash" {
        ami = "${var.ami_id}"
        instance_type = "${var.logstash_instance_type}"
        key_name = "${var.key_name}"
        subnet_id = "subnet-0de41bxxxxxxxxxxxx"
        iam_instance_profile = "ec2_role_for_maagc"
        root_block_device {
            volume_type= "standard"
            volume_size = "30"
          }
        tags = { Name = "Enabling-logstash" }
        security_groups = "${compact(split(",", var.security_groups["security_groups"]))}"

        provisioner "local-exec" {
           command = " echo 'logstash_server_ip: ${aws_instance.ansible-logstash.private_ip}' > elk-vars.yml"
        }

        provisioner "local-exec" {
          command = "ansible-playbook --private-key=/home/sai.d/poc.pem -u ec2-user -i ${aws_instance.ansible-logstash.private_ip}, playbooks/logstash.yml --extra-vars '@elk-vars.yml'"
        }
        depends_on = [aws_instance.ansible-elastic,aws_instance.ansible-kibana,aws_instance.ansible-beats]
}
