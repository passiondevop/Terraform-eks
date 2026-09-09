resource "aws_eks_cluster" "global-cluster" {
  name = var.clustername
  role_arn = aws_iam_role.globalrole.arn
  version = "1.34"
  


  vpc_config {
    subnet_ids = [aws_subnet.pubsub01.id, aws_subnet.pubsub02.id]#aws_subnet.pri01.id, aws_subnet.pri02.id]
  }
  depends_on = [
    aws_iam_role.globalrole
  ]
  tags = {
    Name = "devcluster"
    Environment = var.env
  }
}

# Get the TLS certificate thumbprint from the cluster's OIDC issuer
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.global-cluster.identity[0].oidc[0].issuer
}

# Register the OIDC provider with IAM
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  url             = aws_eks_cluster.global-cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]

  tags = {
    Name        = "eks-oidc-provider"
    Environment = var.env
  }
}

## Add EBS CSI Driver Addon
#resource "aws_eks_addon" "ebs_csi_driver" {
#  cluster_name             = aws_eks_cluster.global-cluster.name
#  addon_name               = "aws-ebs-csi-driver"
#  addon_version            = "v1.32.0-eksbuild.1" # match your EKS version
#  resolve_conflicts        = "OVERWRITE"
#  service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn
#
#  tags = {
#    Name        = "ebs-csi-driver"
#    Environment = var.env
#  }
#}
#
## IAM Role for EBS CSI Driver
#resource "aws_iam_role" "ebs_csi_driver_role" {
#  name = "${var.clustername}-AmazonEKS_EBS_CSI_DriverRole"
#
#  assume_role_policy = jsonencode({
#    Version = "2012-10-17"
#    Statement = [
#      {
#        Effect = "Allow"
#        Principal = {
#          Service = "pods.eks.amazonaws.com"
#        }
#        Action = "sts:AssumeRole"
#      }
#    ]
#  })
#}
#
#resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
#  role       = aws_iam_role.ebs_csi_driver_role.name
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#}