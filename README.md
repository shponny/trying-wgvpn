# Trying Wireguard VPN

Trying to deploy Wireguard VPN on EC2 + Wireguard client on localhost with Ansible and Terraform.

### Requirements
1. Terraform 1.0.9
2. Pipenv
3. Ansible 2.9
4. Testinfra

AWS key credentials - in **~/.aws/credentials** - https://boto3.amazonaws.com/v1/documentation/api/latest/guide/credentials.html


SSH key - look in `main.tf`, `ansible.cfg` and `infratest.sh`

### Run:

Add +x to `install.sh`

```bash
./install.sh
```

## Enable VPN on client:
```bash
wg-quick up wg0
```

## Disable VPN on client:
```bash
wg-quick down wg0
```
