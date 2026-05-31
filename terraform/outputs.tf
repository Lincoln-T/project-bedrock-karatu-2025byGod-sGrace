output "region" {
  value = var.region
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "assets_bucket_name" {
  value = "bedrock-assets-${var.student_id}"
}

output "developer_access_key_id" {
  value     = aws_iam_access_key.developer_view.id
  sensitive = true
}

output "developer_secret_access_key" {
  value     = aws_iam_access_key.developer_view.secret
  sensitive = true
}
