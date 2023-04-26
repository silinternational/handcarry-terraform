terraform {
  cloud {
    organization = "gtis"
    workspaces {
      tags = ["app:wecarry"]
    }
  }
}
