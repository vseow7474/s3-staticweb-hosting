terraform {
  backend "s3" {
    bucket = "sctp-ce8-tfstate"
    key = "vic-s3-static.tfstate"
    region = "ap-southeast-1"
  }
}