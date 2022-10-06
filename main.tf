# data "aws_ami" "debian" {
#     most_recent = true
#     filter {
#         name = "image-id"
#         values = ["ami-09a41e26df464c548"]
#     }
# }

resource "aws_vpc" "default_vpc" {
    cidr_block = "10.41.0.0/16"

    tags = {
        Name = "default-vpc"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.default_vpc.id
    cidr_block = "10.41.10.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "public-subnet"
    }

    map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id = aws_vpc.default_vpc.id
    cidr_block = "10.41.11.0/24"
    availability_zone = "us-east-1b"

    tags = {
        Name = "public-subnet-2"
    }

    map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.default_vpc.id
    cidr_block = "10.41.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
      Name = "private-subnet"
    }
}

resource "aws_subnet" "private_subnet_2" {
    vpc_id = aws_vpc.default_vpc.id
    cidr_block = "10.41.2.0/24"
    availability_zone = "us-east-1b"

    tags = {
      Name = "private-subnet-2"
    }
}

resource "aws_internet_gateway" "gateway_teste" {
    vpc_id = aws_vpc.default_vpc.id    

    tags = {
        Name = "default-gateway"
    }
}

resource "aws_route_table" "default_table" {
    vpc_id = aws_vpc.default_vpc.id

    # route {
    #     cidr_block = "10.41.0.0/16"
    #     gateway_id = aws_internet_gateway.gateway_teste.id
    # }
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gateway_teste.id
    } 

    tags = {
        Name = "default-route-table"
    }
}

resource "aws_route_table" "default_table_2" {
    vpc_id = aws_vpc.default_vpc.id

    # route {
    #     cidr_block = "10.41.0.0/16"
    #     gateway_id = aws_internet_gateway.gateway_teste.id
    # }
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gateway_teste.id
    } 

    tags = {
        Name = "default-route-table-2"
    }
}

resource "aws_route_table_association" "route_table_public" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.default_table.id
    depends_on = [
      aws_route_table.default_table
    ]
}

resource "aws_route_table_association" "route_table_public_2" {
    subnet_id = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.default_table_2.id
    depends_on = [
      aws_route_table.default_table_2
    ]
}

resource "aws_eip" "nat_ip" {
    vpc = true

    depends_on = [
        aws_internet_gateway.gateway_teste
    ]    
}

resource "aws_eip" "nat_ip_2" {
    vpc = true

    depends_on = [
        aws_internet_gateway.gateway_teste
    ]    
}

resource "aws_nat_gateway" "nat_gateway" {
    subnet_id = aws_subnet.public_subnet.id
    allocation_id = aws_eip.nat_ip.id

    tags = {
      Name = "nat-gateway"
    }

    depends_on = [
      aws_subnet.public_subnet,
      aws_eip.nat_ip
    ]
}

resource "aws_nat_gateway" "nat_gateway_2" {
    subnet_id = aws_subnet.public_subnet_2.id
    allocation_id = aws_eip.nat_ip_2.id

    tags = {
      Name = "nat-gateway-2"
    }

    depends_on = [
      aws_subnet.public_subnet,
      aws_eip.nat_ip
    ]
}

resource "aws_route_table" "NAT_route" {
    vpc_id = aws_vpc.default_vpc.id

    # route {
    #     cidr_block = "10.41.0.0/16"
    #     gateway_id = aws_nat_gateway.nat_gateway.id
    # }

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway.id
    }

    tags = {
        Name = "NAT route table"
    }

    depends_on = [
      aws_vpc.default_vpc,
      aws_nat_gateway.nat_gateway
    ]
}

resource "aws_route_table" "NAT_route_2" {
    vpc_id = aws_vpc.default_vpc.id

    # route {
    #     cidr_block = "10.41.0.0/16"
    #     gateway_id = aws_nat_gateway.nat_gateway.id
    # }

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway_2.id
    }

    tags = {
        Name = "NAT route table 2"
    }

    depends_on = [
      aws_vpc.default_vpc,
      aws_nat_gateway.nat_gateway_2
    ]
}

resource "aws_route_table_association" "route_table_private" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.NAT_route.id

    depends_on = [
      aws_subnet.private_subnet,
      aws_route_table.NAT_route
    ]
}

resource "aws_route_table_association" "route_table_private_2" {
    subnet_id = aws_subnet.private_subnet_2.id
    route_table_id = aws_route_table.NAT_route_2.id

    depends_on = [
      aws_subnet.private_subnet_2,
      aws_route_table.NAT_route_2
    ]
}

resource "aws_security_group" "sg_bastion_host" {
    name = "bastion host sg"
    description = "Security group only for bastion hosts"
    vpc_id = aws_vpc.default_vpc.id
}

resource "aws_security_group_rule" "ssh_bastion_host" {
    type = "ingress"
    description = "allow ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.sg_bastion_host.id
}

resource "aws_security_group_rule" "ssh_bastion_host_out" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.sg_bastion_host.id
}

resource "aws_security_group" "rds_sg" {
    name = "rds-sg"
    description = "security group for rds databases" 
    vpc_id = aws_vpc.default_vpc.id
}

resource "aws_security_group_rule" "public_out_rds_sg" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.rds_sg.id
}

resource "aws_security_group_rule" "postgres_in" {
    type = "ingress"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_group_id = aws_security_group.rds_sg.id
    source_security_group_id = aws_security_group.server.id
}

resource "aws_security_group" "server" {
    name = "server-sg"
    description = "Security groups created by terraform"
    vpc_id = aws_vpc.default_vpc.id
}

resource "aws_security_group_rule" "public_out" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.server.id
}

resource "aws_security_group_rule" "public_ssh_in" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    # cidr_blocks = [ "0.0.0.0/0" ]
    security_group_id = aws_security_group.server.id
    source_security_group_id = aws_security_group.sg_bastion_host.id
}

resource "aws_security_group_rule" "public_http_in" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    security_group_id = aws_security_group.server.id
}

resource "aws_security_group_rule" "public_in_https" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.server.id
}



resource "aws_network_interface" "apachewebserver_interface" {
    subnet_id = aws_subnet.public_subnet.id
    private_ips = ["10.41.10.18"]
    security_groups = [ aws_security_group.server.id ]
    depends_on = [
      aws_security_group.server
    ]
}



resource "aws_network_interface" "bastion_host_network" {
    subnet_id = aws_subnet.public_subnet_2.id
    private_ips = ["10.41.11.30"]
    security_groups = [ aws_security_group.sg_bastion_host.id ]
    depends_on = [
     aws_security_group.sg_bastion_host
    ]
}

# resource "aws_eip" "bastion_host_ip" {
#     vpc = true
#     network_interface = aws_network_interface.bastion_host_network.id
#     depends_on = [
#         aws_internet_gateway.gateway_teste
#     ]    
# }

resource "aws_instance" "bastion_host" {
    ami = "ami-09a41e26df464c548"
    instance_type = "t2.micro"

    network_interface {
     network_interface_id = aws_network_interface.bastion_host_network.id
     device_index = 0
    }

    key_name = "default"

    #user_data_base64 = "${base64encode(var.instance_user_data)}"

    tags = {
      Name = "bastion host"
    }

    depends_on = [
      aws_vpc.default_vpc,
      aws_internet_gateway.gateway_teste
    ]
}

data "template_file" "config_file_front" {
    template = templatefile("${path.module}/config-front.yaml",{
        hostname = "web-server"
    })
}

resource "aws_instance" "vm_2" {
    ami = "ami-09a41e26df464c548"
    instance_type = "t2.micro"

    network_interface {
      network_interface_id = aws_network_interface.apachewebserver_interface.id
      device_index = 0
    }

    ebs_block_device {
     device_name = "/dev/xvda"
     volume_type = "gp2"
     volume_size = 10
    }

    #user_data_base64 = "${base64encode(var.instance_user_data)}"
    user_data = data.template_file.config_file_front.rendered

    key_name = "default" 

    depends_on = [
      aws_vpc.default_vpc,
      aws_internet_gateway.gateway_teste
    ]    

    tags = {
        Name = "web server"
    }
}

resource "aws_db_subnet_group" "patrimonio_db_subnet_group" {
    name = "patrimonio_db_subnet_group" 
    subnet_ids = [ aws_subnet.private_subnet.id, aws_subnet.private_subnet_2.id ]

    tags = {
        Name = "Patrimonio DB Subnet group"
    }

}

resource "aws_db_instance" "patrimonio_db" {
    allocated_storage    = var.db.size
    db_name              = var.db.name
    identifier           = var.db.name
    engine               = var.db.engine
    engine_version       = var.db.version
    instance_class       = var.db.instance
    username             = var.db.user
    password             = var.db.password
    skip_final_snapshot  = true
    vpc_security_group_ids = [ aws_security_group.rds_sg.id ]
    db_subnet_group_name = aws_db_subnet_group.patrimonio_db_subnet_group.name
}


resource "aws_s3_bucket" "patrimonio_s3_bucket" {
    bucket = "patrimonio-w1p30qp8y4iyn7cv"
}

resource "aws_s3_bucket_policy" "patrimonio_s3_external_access_policy" {
    bucket = aws_s3_bucket.patrimonio_s3_bucket.id
    policy = file("${path.module}/s3-public-bucket.json")
}

resource "aws_ami_from_instance" "webserver_ami" {
    name = "webserver_ami"
    source_instance_id = aws_instance.vm_2.id
    depends_on = [
      aws_instance.vm_2
    ]
}

data "aws_instance" "webserver_instance" {
    instance_id = aws_instance.vm_2.id
}

data "aws_ami" "webserver_ami_created" {
    filter {
      name = "name"
      values = [ "webserver_ami" ]
    }
    depends_on = [
      aws_ami_from_instance.webserver_ami
    ]
}

resource "aws_launch_template" "webserver_template" {
    image_id = aws_ami_from_instance.webserver_ami.id
    instance_type = "t2.micro"
    depends_on = [
      data.aws_ami.webserver_ami_created
    ]
}

# resource "aws_autoscaling_group" "webserver_scaling" {
#     desired_capacity = 1
#     max_size = 3
#     min_size = 1

#     vpc_zone_identifier = [ aws_subnet.private_subnet.id, aws_subnet.private_subnet_2.id ]

#     launch_template {
#       id = aws_launch_template.webserver_template.id
#       version = "$Default"
#     }
# }

# resource "aws_lb" "appbalancer00" {
#     name = "balancer-00"  
#     internal = false
#     load_balancer_type = "application"
#     subnets = [ aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id ]
#     depends_on = [
#       aws_autoscaling_group.webserver_scaling
#     ]
    
# }

# resource "aws_lb_target_group" "alb_port_80" {
#   name     = "port-80-lb"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.default_vpc.id
# }

# resource "aws_autoscaling_attachment" "balancer00_autoscaling" {
#     autoscaling_group_name = aws_autoscaling_group.webserver_scaling.id
#     alb_target_group_arn = aws_lb_target_group.alb_port_80.arn  

#     #elb = aws_lb.appbalancer00.id
#     depends_on = [
#       aws_lb_target_group.alb_port_80,
#       aws_autoscaling_group.webserver_scaling
#     ]
# }
