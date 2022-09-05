#---------------------------------------
#example with exec with bash and python
#---------------------------------------


resource "null_resource" "command1" {
    provisioner "local-exec" {
        command = "echo Ololo $(date) >> log.txt"
    }  
}

resource "null_resource" "command2" {
    depends_on = [
      null_resource.command1
    ]
    provisioner "local-exec" {
        command = "ping -c 5 www.google.com"
    }
}

resource "null_resource" "command3" {
    provisioner "local-exec" {
        interpreter = [
          "python3", "-c"
        ]
        command = "print('hello, world')"
    }
}

resource "null_resource" "command4" {
    depends_on = [
        null_resource.command3, null_resource.command2
    ]
    provisioner "local-exec" {
        #use environment variables $NAME1 $NAME2 $NAME3 specified below in block environment
        command = "echo Ololo $(date) $NAME1 $NAME2 $NAME3 >> log.txt"
        environment = { #create environment variables for this command
          NAME1 = "Vasya"
          NAME2 = "Petya"
          NAME3 = "Ivan"
         }
    }
}

resource "aws_instance" "TerForm-Test-skiff" {
  ami = "ami-052efd3df9dad4825"
  instance_type = "t3.nano"
  subnet_id = "subnet-077130cf09bf07223"
  provisioner "local-exec" {
    command = "echo Hello from skiff"
  }
}