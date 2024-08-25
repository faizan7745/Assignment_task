#!/bin/bash
#shebang to start bash script

# File path of Configuration file
CONF_FILE="./security_audit.conf"

# Load configuration file if exists
if [ -f "$CONF_FILE" ]; then
    source "$CONF_FILE"
else
    echo "Configuration file is not available. going with default settings."
fi

# Function to audit users and groups
Audit_users_and_groups() {
    echo "# User and Group Audit  Are: #"
    echo "Listing all users and groups:"
    cut -d: -f1 /etc/passwd
    cut -d: -f1 /etc/group
    
    echo "Checking for users with UID 0 (root privileges):"
    awk -F: '($3 == 0) {print $1}' /etc/passwd
    
    echo "Checking for users without passwords:"
    awk -F: '($2 == "" ) {print $1}' /etc/shadow
    
    echo "Checking for users with weak passwords:"

    # john --wordlist=weak_password_list /etc/shadow
}

# To check file and directory permissions
Audit_file_permissions() {
    echo "# File and Directory Permissions #"
    echo "Checking for world-writable files and directories:"
    find / -xdev -type d -perm -0002 -print 2>/dev/null
    find / -xdev -type f -perm -0002 -print 2>/dev/null
    
    echo "Checking for .ssh directories with secure permissions:"
    find /home -maxdepth 2 -type d -name ".ssh" -exec chmod 700 {} \;
    
    echo "Checking for files with SUID/SGID bits set:"
    find / -xdev -type f \( -perm -4000 -o -perm -2000 \) -exec ls -ld {} \;
}

# Function to audit running services
Audit_services() {
    echo "# Service Audit #"
    echo "Listing all running services:"
    systemctl list-units --type=service --state=running
    
    echo "Checking for unauthorized services:"
    # Define a list of authorized services and check against it
    AUTHORIZED_SERVICES=("sshd" "iptables" "ufw")
    for service in $(systemctl list-units --type=service --state=running | awk '{print $1}'); do
        if [[ ! " ${AUTHORIZED_SERVICES[@]} " =~ " ${service} " ]]; then
            echo "Unauthorized service found: $service"
        fi
    done
}

# Function to check firewall and network security
Audit_firewall_network() {
    echo "### Firewall and Network Security ###"
    echo "Checking if a firewall is active:"
    if systemctl is-active --quiet ufw; then
        echo "UFW is active."
    elif systemctl is-active --quiet iptables; then
        echo "iptables is active."
    else
        echo "No active firewall found!"
    fi
    
    echo "Listing open ports and their associated services:"
    ss -tuln
    
    echo "Checking for IP forwarding:"
    sysctl net.ipv4.ip_forward
    sysctl net.ipv6.conf.all.forwarding
}

# Function to check IP and network configuration
Audit_ip_network() {
    echo "### IP and Network Configuration ###"
    echo "Listing all IP addresses:"
    ip addr show
    
    echo "Identifying public vs private IPs:"
    ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | while read -r ip; do
        if [[ "$ip" =~ ^(10|172\.(1[6-9]|2[0-9]|3[01])|192\.168)\. ]]; then
            echo "Private IP: $ip"
        else
            echo "Public IP: $ip"
        fi
    done
}

# Function to check for security updates and patching
Audit_updates() {
    echo "### Security Updates and Patching ###"
    echo "Checking for available updates:"
    apt-get update && apt-get upgrade -s | grep "^Inst"
}

# Function to review log monitoring
Audit_logs() {
    echo "### Log Monitoring ###"
    echo "Checking for suspicious log entries:"
    grep "Failed password" /var/log/auth.log | tail -10
}

# Function to harden the server
harden_server() {
    echo "### Server Hardening ###"
    
    echo "Disabling password authentication for SSH:"
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
    
    echo "Disabling IPv6:"
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    sysctl -p
    
    echo "Setting GRUB bootloader password:"
    grub-mkpasswd-pbkdf2 | tee -a /etc/grub.d/40_custom
    update-grub
    
    echo "Configuring automatic updates:"
    apt-get install unattended-upgrades
    dpkg-reconfigure --priority=low unattended-upgrades
}

# Function for custom security checks
custom_security_checks() {
    echo "### Custom Security Checks ###"
    # Load and run custom checks from configuration file
    if [ -f "$CUSTOM_CHECKS_FILE" ]; then
        source "$CUSTOM_CHECKS_FILE"
    else
        echo "No custom security checks file found."
    fi
}

# Function to generate a summary report
generate_report() {
    echo "### Security Audit and Hardening Report ###"
    echo "Report generated on $(date)"
    # Summarize all findings
}

# Main script execution
main() {
    Audit_users_and_groups
    Audit_file_permissions
    Audit_services
    Audit_firewall_network
    Audit_ip_network
    Audit_updates
    Audit_logs
    harden_server
    custom_security_checks
    generate_report
}

main "$@"
