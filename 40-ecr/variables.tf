variable "components" {
  type    = list(string)
  default = ["catalogue", "cart", "user", "shipping", "payment", "frontend"]
}

variable "project_name" {
    default = "roboshop"
}
