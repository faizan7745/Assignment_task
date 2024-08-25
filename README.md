# Assignment_task

####  Monitoring System Resources for a Proxy Server  ####
-  Monitoring System Resources for a Proxy Server -
 This Bash script will provide real-time Monitoring of and this script will refresh the data every few seconds, providing real-time insights:

1] Top 10 most used applications (CPU and memory).
2] Network monitoring (concurrent connections, packet drops, data in/out).
3] Disk usage and load average.
4] System load and memory usage.
5] Process monitoring.
6] Service monitoring.
A custom dashboard with command-line switches for specific parts.

Steps -
1] Create a file for example monitor.sh
2] give the permission using chmod to make script run
3] Now run the script by providing different command line switches for what we want like
  - Usage: ./monitor4.sh [options]
Options:
  -Top_app           for Displaying Top 10 most meomory And cpu consuming app
  -memory,           for memory usage information
  -network           for network usage information
  -disk              for disk usage information
  -processes         for processes usage information
  -services          for essential services status
  -all               To Show all dashboard information
  -h                for help message and exit
  -cpu               for CPU usage information

