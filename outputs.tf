output "ec2_webserver_instance" {
    value = "${ data.aws_instance.webserver_instance.id }"
}

# output "ami_webserver_id" {
#     value = data.aws_ami.webserver_ami_created.id  
# }