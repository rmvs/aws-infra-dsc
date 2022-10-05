# resource "aws_launch_template" "webserver_template" {
#     name = "webserver_template"
#     block_device_mappings {
#       device_name = "/dev/xvda1"

#       ebs {
#         volume_size = 10
#       }    
      
#     }
#     vpc_security_group_ids = [ aws_security_group.server.id ]
# }