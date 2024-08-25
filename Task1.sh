#!/bin/bash

# Used function in this Script.
usage() i{
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -Top_app           for Displaying Top 10 most meomory And cpu consuming app"
    echo "  -memory,           for memory usage information"
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
display_top_apps() {
    echo "Top 10 Most Used Applications (CPU and Memory) "
    echo "Top 10 CPU consuming processes:"
    ps aux --sort=-%cpu | head -n 11 | awk '{print $1, $2, $3, $4, $11}'

    echo "Top 10 Memory consuming processes:"
    ps aux --sort=-%mem | head -n 11 | awk '{print $1, $2, $3, $4, $11}'
    echo
}
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
    display_top_apps
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

# Refresh interval
refresh_interval=5

# Variables to track which sections to display
display_flag=false
cpu_flag=false
memory_flag=false
network_flag=false
disk_flag=false
processes_flag=false
services_flag=false
all_flag=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -cpu)
            cpu_flag=true
            ;;
        -memory)
            memory_flag=true
            ;;
        -network)
            network_flag=true
            ;;
        -disk)
            disk_flag=true
            ;;
        -processes)
            processes_flag=true
            ;;
        -services)
            services_flag=true
            ;;
        -Top_app)
           display_flag=true
            ;;
        -all)
            all_flag=true
            ;;
        [0-9]*)
            refresh_interval=$1
            ;;
        *)
            echo "Invalid option: $1"
            usage
            ;;
    esac
    shift
done

# Main loop to refresh the dashboard
while true; do
    clear
    if $all_flag; then
        show_all
    else
        if $cpu_flag; then
            cpu_usage
        fi
        if $memory_flag; then
            memory_usage
        fi
        if $network_flag; then
            network_usage
        fi
        if $disk_flag; then
            disk_usage
        fi
        if $processes_flag; then
            processes_usage
        fi
        if $services_flag; then
            services_status
        fi
        if $display_flag; then
            display_top_apps
        fi
    fi
    sleep $refresh_interval
done
