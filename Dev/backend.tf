terraform {
  backend "s3" {
    bucket = "ssstfstate"
    key    = "dev.tfstate"
    region = "us-west-2"
  }
}