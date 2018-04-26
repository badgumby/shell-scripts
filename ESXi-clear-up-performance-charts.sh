# Get count of files in folder
find . -type f | wc -l

# Delete Java perfcharts older than 30 days
find /storage/log/vmware/perfcharts/*.hprof -mtime +30 -exec rm {} \;
