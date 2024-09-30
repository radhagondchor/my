output "vpc_id" {
  value = aws_vpc.elastic_vpc.id
}

output "public_subnet_1_id" {
  value = aws_subnet.elastic_pub_subnet_1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.elastic_pub_subnet_2.id
}

output "private_subnet_1_id" {
  value = aws_subnet.elastic_priv_subnet_1.id
}

output "private_subnet_2_id" {
  value = aws_subnet.elastic_priv_subnet_2.id
}
