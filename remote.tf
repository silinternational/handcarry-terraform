data "terraform_remote_state" "common" {
  backend = "remote"
  config = {
    organization = "gtis"
    workspaces = {
      name = var.tf_remote_common
    }
  }
}
