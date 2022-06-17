terraform {
  cloud {
    organization = "janderton-sandbox"
    workspaces {
      tags = ["tfc-blog-example"]
    }
  }
}
