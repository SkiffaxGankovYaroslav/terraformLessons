#при импорте вся информация сохраняется в state, но при попытке apply terraform не считает их, поскольку он применяет данные лишь из кода *.tf
resource "aws_instance" "existing_server" {
    
}