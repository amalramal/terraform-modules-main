resource "aws_subnet" "private_subnets" {
  for_each = local.private_networks_by_az

  availability_zone = each.value["availability_zone"]
  cidr_block        = each.value["cidr_block"]
  vpc_id            = aws_vpc.vpc.id
  tags = merge(
    var.subnet_tags,
    var.private_subnet_tags,
    var.vpc_tags,
    {
      Name        = "${each.value["name"]}-sn"
      NetworkType = "private"
    }
  )
}

locals {
  # When enable_single_nat_gw, pick just the first public subnet for the NAT GW;
  # otherwise create one NAT GW per AZ.
  _igw_public_subnets = (
    var.enable_single_nat_gw && length(local.public_networks_by_az) > 0
    ? { keys(local.public_networks_by_az)[0] : local.public_networks_by_az[keys(local.public_networks_by_az)[0]] }
    : local.public_networks_by_az
  )
}

resource "aws_eip" "nat_eip" {
  # We don't need EIPs if we dont have an IGW
  for_each = var.enable_igw ? local._igw_public_subnets : {}

  domain = "vpc"
  tags = merge(
    var.vpc_tags,
    {
      Name = "${each.value["name"]}-nat-ip"
    }
  )
}

resource "aws_nat_gateway" "nat_gateway" {
  # Only create NAT Gateways if we have public subnets to attach them to
  for_each = local.num_public_subnets > 0 && var.enable_igw ? local._igw_public_subnets : {}

  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = aws_subnet.public_subnets[each.key].id
  tags = merge(
    var.vpc_tags,
    {
      Name = "${each.key}-nat-gw"
    }
  )
}

resource "aws_route_table" "private_rt" {
  for_each = local.private_networks_by_az

  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.vpc_tags,
    {
      Name        = "${each.value["name"]}-rt"
      NetworkType = "private"
    }
  )
}

resource "aws_route" "private_nat_route" {
  # We only need routes if there are public subnets with an IGW
  for_each = local.num_public_subnets > 0 && var.enable_igw ? local.private_networks_by_az : {}

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.enable_single_nat_gw ? aws_nat_gateway.nat_gateway[keys(local._igw_public_subnets)[0]].id : aws_nat_gateway.nat_gateway[each.key].id
  route_table_id         = aws_route_table.private_rt[each.key].id
}

resource "aws_route_table_association" "private_route_table_assciation" {
  for_each = local.private_networks_by_az

  route_table_id = aws_route_table.private_rt[each.key].id
  subnet_id      = aws_subnet.private_subnets[each.key].id
}
