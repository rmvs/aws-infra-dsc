# variable instance_user_data {
#     type = string
# }

# variable ami_webserver_id {
#     type = string
# }

variable db {
    type = object({
        user = string,
        password = string,
        name = string,
        instance = string,
        engine = string,
        version = string,
        size = number
    })
}