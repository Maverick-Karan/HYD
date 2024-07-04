// Python script to delete default VPC
resource "null_resource" "delete_default_vpc" {
  triggers = {
   always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOT
    python3 delete_default_vpc.py ${var.new_account_id}
    EOT
  }
}