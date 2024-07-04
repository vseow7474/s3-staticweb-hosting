terraform {
  backend "s3" {
    bucket = "sctp-ce6-tfstate"
    key = "jaz-s3-static.tfstate"
    region = "ap-southeast-1"
  }
}