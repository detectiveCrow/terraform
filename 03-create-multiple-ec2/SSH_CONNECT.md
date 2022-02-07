## Generate SSH key pair for configuration

```
ssh-keygen -t rsa -b 2048 -f $HOME/.ssh/aws/aws_key
```

## Add created key info to terraform file

```
resource "aws_instance" "ec2_example" {

    ami = "ami-0767046d1677be5a0"  
    instance_type = "t2.micro" 
    key_name= "aws_key"

    connection {
        type        = "ssh"
        host        = self.public_ip
        user        = "ubuntu"
        private_key = file("/root/.ssh/aws/aws_key")
        timeout     = "5m"
    }
}
```

## Connect using public key

```
ssh -i "~/.ssh/aws/aws_key" ubuntu@[ip address of instance]
```