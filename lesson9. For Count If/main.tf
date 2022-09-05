#------------------------------
#cycles and loops
#------------------------------


#variable for count loop
variable "users_list_skiff" {
    description = "list of IAM users to create"
    default = ["ololoev1", "ololoev2", "ololoev3", "pushkin","alalaev1"]
}

#count loop
resource "aws_iam_user" "users_loop" {
    count = length(var.users_list_skiff)
    name = element(var.users_list_skiff, count.index)
    tags = {
        creator = "yaroslav.gankov"
        learning = "Terraform"
    }
}

#for example output all information about users
output "created_iam_users_all" {
    value = aws_iam_user.users_loop
}

#output only the users ID (without all other information)
output "created_iam_users_ID" {
    value = aws_iam_user.users_loop[*].id
}

#for loop. output with cycle variables (user11 aka "i")
output "created_iam_users_custom" {
    value = [
        for user11 in aws_iam_user.users_loop:
        "Hello: ${user11.name} with ARN: ${user11.arn}"
    ]
}

#for loop. Create custom map
output "created_iam_users_map" {
    value = {
        for user in aws_iam_user.users_loop:
        user.unique_id => user.id
        #output must be like "AIDASNA2YUEPDWVIDGX4C" = "ololoev2"
    }
}

#if with for
output "custom_if_length" {
    value = [
        for x in aws_iam_user.users_loop:
        x.name
        if length(x.name) == 7
    ]
}