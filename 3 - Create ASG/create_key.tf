resource "aws_key_pair" "kris" {
  key_name = "kris-key-pair"
  public_key = "${file("key.pub")}"
}