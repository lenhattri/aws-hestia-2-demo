locals {
  merged_tags = merge(var.default_tags, {
    Module = "eks"
  })

  log_retention = var.is_lab ? var.cloudwatch_log_retention_days : var.log_retention_in_days
  node_instance_type = var.is_lab ? var.eks_instance_type : var.node_instance_type
  node_min_size      = var.is_lab ? var.eks_node_min : var.node_min_size
  node_max_size      = var.is_lab ? var.eks_node_max : var.node_max_size
  node_desired_size  = min(max(var.node_desired_size, local.node_min_size), local.node_max_size)
}

data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/${var.kubernetes_version}/amazon-linux-2/recommended/image_id"
}

locals {
  resolved_node_ami_id = var.node_ami_id != "" ? var.node_ami_id : jsondecode(data.aws_ssm_parameter.eks_ami.value).image_id
}

resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = local.log_retention
  kms_key_id        = var.log_kms_key_arn
  tags              = local.merged_tags
}

resource "aws_iam_role" "cluster" {
  name               = "${var.cluster_name}-eks-cluster"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume.json
  tags               = local.merged_tags
}

data "aws_iam_policy_document" "cluster_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "cluster_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ])

  policy_arn = each.value
  role       = aws_iam_role.cluster.name
}

resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-cluster"
  description = "Cluster communication"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.merged_tags, {
    Name = "${var.cluster_name}-cluster"
  })
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [aws_security_group.cluster.id]
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types
  encryption_config {
    provider {
      key_arn = var.secrets_kms_key_arn
    }
    resources = ["secrets"]
  }

  depends_on = [aws_cloudwatch_log_group.cluster, aws_iam_role_policy_attachment.cluster_policies]
  tags       = local.merged_tags
}

resource "aws_iam_role" "node_group" {
  name               = "${var.cluster_name}-nodegroup"
  assume_role_policy = data.aws_iam_policy_document.node_assume.json
  tags               = local.merged_tags
}

data "aws_iam_policy_document" "node_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ])

  policy_arn = each.value
  role       = aws_iam_role.node_group.name
}

resource "aws_launch_template" "node" {
  name_prefix   = "${var.cluster_name}-lt-"
  image_id      = local.resolved_node_ami_id
  instance_type = local.node_instance_type

  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.node_volume_size
      volume_type           = "gp3"
      encrypted             = true
      kms_key_id            = var.node_volume_kms_key_arn != "" ? var.node_volume_kms_key_arn : null
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.merged_tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.merged_tags
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = local.node_desired_size
    max_size     = local.node_max_size
    min_size     = local.node_min_size
  }

  update_config {
    max_unavailable_percentage = 33
  }

  ami_type      = "AL2_x86_64"
  capacity_type = var.node_capacity_type
  launch_template {
    id      = aws_launch_template.node.id
    version = aws_launch_template.node.latest_version
  }

  tags = local.merged_tags

  depends_on = [aws_iam_role_policy_attachment.node_policies]
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.oidc_thumbprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  tags            = local.merged_tags

  depends_on = [aws_eks_cluster.this]
}

data "aws_iam_policy_document" "irsa_assume" {
  for_each = var.irsa_roles

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.service_account}"]
    }
  }
}

resource "aws_iam_role" "irsa" {
  for_each           = var.irsa_roles
  name               = "${var.cluster_name}-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume[each.key].json
  tags               = local.merged_tags
}

resource "aws_iam_role_policy" "irsa_inline" {
  for_each = var.irsa_roles

  role   = aws_iam_role.irsa[each.key].id
  policy = each.value.policy_json
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.this.name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = var.irsa_roles["alb"].service_account
  }

  depends_on = [aws_iam_role.irsa]
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  depends_on = [aws_eks_node_group.this]
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.this.name
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = var.irsa_roles["autoscaler"].service_account
  }

  depends_on = [aws_iam_role.irsa]
}

resource "helm_release" "fluent_bit" {
  name       = "aws-for-fluent-bit"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  namespace  = "kube-system"

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = var.irsa_roles["fluentbit"].service_account
  }

  depends_on = [aws_iam_role.irsa]
}
