# linux-network-basics.md

## Check the machine's IP address

Show all network interfaces and IP addresses:

```bash
ip addr
```

Show IPv4 addresses only:

```bash
hostname -I
```

(Older systems may use `ifconfig`.)

## DNS & Host Configuration

### Check the DNS in use

```bash
cat /etc/resolv.conf
# Example output:
# nameserver 127.0.0.53
# options edns0 trust-ad
```
### Map hosts (/etc/hosts)

```bash
sudo vi /etc/hosts
# Example entries:
# 127.0.1.1 lab-poc-nfs lab-poc-nfs
# 127.0.0.1 localhost
```

### Add a hostname

```bash
hostname
# Example output (shows current hostname):
# lab-poc-nfs

sudo hostnamectl set-hostname myserver
# Re-login or reboot may be required to see it everywhere.
```

## DNS & Network Diagnostics

### DNS Lookup

#### Using `dig`:

```bash
dig example.com
# Example (short):
dig +short example.com
# Example (MX):
dig MX example.com
```

#### Using `nslookup`:

```bash
nslookup example.com
# Specify DNS:
nslookup example.com 8.8.8.8
```

#### Using `host`:

```bash
host example.com
# Only A record (IP):
host -t A example.com
```

### Traceroute

```bash
# Install (Ubuntu/Debian):
sudo apt install traceroute
# Run:
traceroute example.com
# Example output:
# Command 'traceroute' not found, but can be installed with:
# sudo apt install inetutils-traceroute  # version 2:2.2-2ubuntu0.1, or
# sudo apt install traceroute            # version 1:2.1.0-2

# Alternative:
tracepath example.com
# Example output:
#  1?: [LOCALHOST]                      pmtu 1500
#  1:  _gateway                                              0.257ms
#  1:  _gateway                                              0.223ms
#  2:  103.138.176.254                                       0.802ms asymm  3
#  3:  203-154-129-169.inter.inet.co.th                      0.830ms asymm  4
#  4:  203-150-215-110.inter.net.th                          1.077ms asymm  5
```

## Change SSH port

```bash
# Edit SSH server config:
sudo vi /etc/ssh/sshd_config
# Change from:
#   #Port 22
# to:
#   Port 2222

# Restart SSH:
sudo systemctl restart sshd
# or (Ubuntu/Debian):
sudo systemctl restart ssh

# Allow firewall (UFW example):
sudo ufw allow 2222/tcp

# Next time connect:
ssh -p 2222 user@server-ip
```

## Test connectivity to a specific port (telnet)

```bash
# Install:
sudo apt install telnet    # Ubuntu / Debian
sudo yum install telnet    # CentOS / RHEL

# Test connection:
telnet 103.138.176.223 80
# Example result:
# Trying 103.138.176.223...
# Connected to 103.138.176.223.
# Meaning:
#  - Connected → port open
#  - Connection refused → service not listening
#  - Timed out → firewall or routing issue
```