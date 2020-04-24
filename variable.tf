variable "security_groups" {
  description = " security groups"
  type = "map"
  default = { security_groups = "sg-0884d237xxxxxxxx,sg-0707e89axxxxxxxxxx" }
}

variable "ami_id" {
  description = "ID of AMI to use for the instance"
  default = "ami-0c322300a1dd5dc79"
}

variable "elastic_instance_type" {
  description = "The type of instance to start"
  default = "t2.large"
}

variable "kibana_instance_type" {
  description = "The type of instance to start"
  default = "t2.micro"
}

variable "beats_instance_type" {
  description = "The type of instance to start"
  default = "t2.micro"
}


variable "logstash_instance_type" {
  description = "The type of instance to start"
  default = "t2.micro"
}

variable "key_name" {
  description = "The key name to use for the instance"
  default     = "maagcpoc"
}

