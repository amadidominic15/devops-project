variable "environment" {}
variable "project" {}
variable "instance_type" {}

variable "acm_certificate_arn" {
  default = "arn:aws:acm:us-east-1:048058681621:certificate/78cc8397-6387-4772-b5c0-dbf87f872666"
}
variable "SOURCE_GMAIL_ID"{
  description = "Source GMAIl Id"
  default = "preciousekama2@gmail.com"
}
variable "DESTINATION_GMAIL_ID"{
  description = ""
  default ="preciousekama2@gmail.com"
}
variable "alert_smtp_host" {
  default = "smtp.gmail.com:587"
}
variable "alert_email_password"{
  description = "Source Auth Password"
  default ="eumqeqwngvyyrbqg"
}
variable "domain_name" {
  default = "sinjohgroupinternational.info"
}

variable "allow_ip" {
  default = ["0.0.0.0/0"]
}