output "ec2_webserver_instance" {
    value = "${ data.aws_instance.webserver_instance.id }"
}