variable "access_key" {
  description = "AWS access key"
  default     = "ACCESS_KEY"
}
variable "secret_key" {
  description = "AWS secret access key"
  default     = "SECRET_KEY"
}
variable "region" {
  description = "AWS region to host your network"
  default     = "us-east-1"
}
variable "instance_type" {
  default = "t2.nano"
}
variable "ami" {
  default = "ami-13be557e"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}
resource "aws_instance" "example" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
}
resource "aws_eip" "ip" {
  instance = "${aws_instance.example.id}"
}
