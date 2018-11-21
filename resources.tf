# Define SSH key pair for our instances
resource "aws_key_pair" "padma_key" {
  key_name = "My_new_private_pearson_usest1"
  #public_key = "${file("${var.key_path}")}"
}

# Define webserver inside the public subnet
resource "aws_instance" "wb" {
   ami  = "${var.ami}"
   instance_type = "t1.micro"
   key_name = "My_new_private_pearson_usest1"
   subnet_id = "${aws_subnet.padma-public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.padma-sgweb.id}"]
   associate_public_ip_address = true
   source_dest_check = false
   user_data = "${file("install.sh")}"

  tags {
    Name = "webserver"
  }
}