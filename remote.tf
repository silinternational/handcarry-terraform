data "terraform_remote_state" "common" {
  backend = "remote"
  config = {
    organization = split("/", var.tf_remote_common)[0]
    workspaces = {
      name = split("/", var.tf_remote_common)[1]
    }
  }
}
