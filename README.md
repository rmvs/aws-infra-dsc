# aws-infra-dsc

This code is intended for creating an AWS cloud infrastrucure consiting of one VPC with two subnets (public and private).
Bellow diagram describes the public and private resources.

Create a file called terraform.tfvars (same project folder)

```sh
db = {
    user = <db user>
    password = <db password>,
    name = <db name>,
    instance = <db instance class>,
    engine = <db engine>,
    version = <db version>,
    size = <db size>
}
```

This is required for provisioning the RDS database

Set the AWS access key and secret appropriately

```sh
 export AWS_ACCESS_KEY_ID=
 export AWS_SECRET_ACCESS_KEY= 
 export AWS_REGION=
```
