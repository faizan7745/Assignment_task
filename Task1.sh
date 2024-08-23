#!/bin/bash

# Used function in this Script.
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -memory,            for memory usage information"
    echo "  -network           for network usage information"
    echo "  -disk              for disk usage information"
    echo "  -processes         for processes usage information"
    echo "  -services          for essential services status"
    echo "  -all               To Show all dashboard information"
    echo "  -h                for help message and exit"
    echo "  -cpu               for CPU usage information"

    exit 1
}

# To Dispaly Top 10 Most Used Applications:

cpu_usage() {
    echo "------------------ CPU Usage ------------------"
    top -b -n 1 | head -n 12 | tail -n 5
    echo
}

# Function which will display memory usage.
memory_usage() {
    echo "---------------- Memory Usage -----------------"
    free -h
    echo
}

# Function to display network usage information
network_usage() {
    echo "--------------- Network Monitoring -------------"
    echo "Concurrent connections:"
    ss -s | grep "TCP:" | awk '{print $2}'
    echo "Packet drops:"
    netstat -i | awk '{print $1, $3, $7}' | column -t | grep -v "^Iface"
    echo "Network traffic (MB):"
    ifconfig | grep "RX packets" -A 1 | grep "bytes" | awk '{print $2, $6}'
    echo
}

# To display disk usage
disk_usage() {
    echo "---------------- Disk Usage -------------------"
    df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output; do
        echo $output
        usep=$(echo $output | awk '{ print $1}' | sed 's/%//g')
        partition=$(echo $output | awk '{ print $2 }')
        if [ $usep -ge 80 ]; then
            echo "Warning: Partition $partition is using more than 80% of disk space."
        fi
    done
    echo
    echo "Current load average:"
    uptime | awk -F'load average:' '{ print $2 }'
    echo
}

# To display processes usage 
processes_usage() {
    echo "--------------- Process Monitoring -------------"
    echo "Number of active processes:"
    ps aux | wc -l
    echo "Top 5 processes by CPU usage:"
    ps aux --sort=-%cpu | head -n 6
    echo "Top 5 processes by memory usage:"
    ps aux --sort=-%mem | head -n 6
    echo
}

# To display essential services status
services_status() {
    echo "--------------- Service Monitoring --------------"
    for service in sshd nginx apache2 iptables; do
        if systemctl is-active --quiet $service; then
            echo "$service is running"
        else
            echo "$service is not running"
        fi
    done
    echo
}

# To display all dashboard information
show_all() {
    cpu_usage
    memory_usage
    network_usage
    disk_usage
    processes_usage
    services_status
}

# command-line switches to view specific parts of the dashboard
if [[ $# -eq 0 ]]; then
    usage
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -cpu)
            cpu_usage
            ;;
        -memory)
            memory_usage
            ;;
        -network)
            network_usage
            ;;
        -disk)
            disk_usage
            ;;
        -processes)
            processes_usage
            ;;
        -services)
            services_status
            ;;
        -all)
            show_all
            ;;
        *)
            echo "Invalid option: $1"
            usage
            ;;
    esac
    shift
done
