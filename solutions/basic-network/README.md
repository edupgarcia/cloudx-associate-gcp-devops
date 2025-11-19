# Basic Network Solution

This solution implements a basic VPC network on GCP with:
- Custom VPC with /24 subnet
- Cloud NAT for internet access from private instances
- Bastion host with IP-restricted SSH access
- Private workstation instance (no public IP)
- Private Google Access enabled

## Execution Order

Run the scripts in sequence:

```bash
# 1. Setup environment variables and enable APIs
source 1-setup.sh

# Update your external IP
export EXTERNAL_IP="$(curl -s ifconfig.me)/32"

# 2. Create VPC and subnet
./2-vpc.sh

# 3. Create Cloud NAT
./3-nat.sh

# 4. Create firewall rules
./4-fw.sh

# 5. Create bastion host
./5-bastion-host.sh

# 6. Create workstation instance
./6-workstation.sh
```

## Testing

Test SSH access and connectivity:

```bash
cd test

# 1. SSH to bastion host
./1-bastion-ssh.sh

# 2. SSH to workstation via bastion
./2-workstation-ssh.sh
```

Once connected to the workstation:
```bash
# Test internet connectivity
sudo apt-get update

# Test Private Google Access (should not go over public internet)
traceroute storage.googleapis.com
```

## Acceptance Criteria

✓ Can login to bastion host only from allowed IP addresses  
✓ All hosts can reach public Internet via Cloud NAT  
✓ Requests to GCP APIs on Workstation use Private Google Access  
✓ Workstation has no public IP address  

## Cleanup

To delete all resources:
```bash
source 1-setup.sh
./99-project-cleanup.sh
```

## Architecture

- **VPC**: Custom VPC network with single /24 subnet
- **Cloud NAT**: Provides internet access for instances without public IPs
- **Bastion Host**: Public instance with SSH access restricted by source IP
- **Workstation**: Private instance accessible only through bastion
- **Firewall Rules**: Control SSH access and internal communication
- **Private Google Access**: Enabled on subnet for GCP API access
