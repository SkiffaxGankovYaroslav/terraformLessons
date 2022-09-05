variable "name_user" {
    default = "petya"
}

#генерация случайной строки
resource "random_string" "rds_password" {
    length = 12
    special = true #allow to use special characters
    override_special = "!#$&" #allowed (valid) characters

    #при изменении каких условий нужно заново генерировать строку-пароль
    keepers = {
        kepeer1 = var.name_user
    }
}

#save password ot AWS SSM Parameter Store
resource "aws_ssm_parameter" "rds_password" {
    name = "/prod/mysql"
    description = "Master Password for MySQL"
    type = "SecureString"
    value = random_string.rds_password.result
}

data "aws_ssm_parameter" "my_rds_password" {
    depends_on = [
      aws_ssm_parameter.rds_password
    ]
    name = "/prod/mysql"
}

output "password_MySQL" {
  value = data.aws_ssm_parameter.my_rds_password.value
  sensitive = true
}