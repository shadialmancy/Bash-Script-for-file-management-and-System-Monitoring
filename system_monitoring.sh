#!/bin/bash
# function display_system_monitoring() {
#     while true; do
#     echo "1) System Information Display"
#     echo "2) CPU Usage Monitoring"
#     echo "3) Memory Usage Monitoring"
#     echo "4) CPU Usage Monitoring"
#     echo "5) Logging and Report"
#     echo "6) Back"
#     read choice
#     case $choice in
#     1) system_information_display ;;
#     2) monitorCpuUsage ;;
#     3) display_memory_usage ;;
#     4) display_disk_usage ;;
#     5) logging_and_report ;;
#     6) break ;;
#     *) echo "invalid option"
#     esac
#     done
# }
function display_system_monitoring() {
    while true; do
        choice=$(yad --list --title="System Monitoring Menu"  --column="Option" \
            "1. System Information Display" \
            "2. CPU Usage Monitoring" \
            "3. Memory Usage Monitoring" \
            "4. Disk Usage Monitoring" \
            "5. Logging and Report" \
            --width=400 --height=300 \
            --button=gtk-ok:0 --button=gtk-cancel:1)

        # Check if user clicked "Cancel"
        if [[ $? -eq 1 ]]; then
            break
        fi
        # Determine which option was selected
        case $(echo $choice | cut -f1 -d"|") in
            "1. System Information Display") system_information_display ;;
            "2. CPU Usage Monitoring") monitor_cpu_usage ;;
            "3. Memory Usage Monitoring") display_memory_usage ;;
            "4. Disk Usage Monitoring") display_disk_usage ;;
            "5. Logging and Report") logging_and_report ;;
            *) break ;;
        esac
    done
}

# display_disk_usage() {
#     echo "Disk Space Usage:"
#     df -h --output=source,fstype,size,used,avail,pcent,target | grep -v "tmpfs\|udev"
#     echo ""
# }

function display_disk_usage() {
    disk_usage=$(df -h --output=source,fstype,size,used,avail,pcent,target | grep -v "tmpfs\|udev")
    
    yad --text-info \
        --title="Disk Space Usage" \
        --width=600 --height=400 \
        --text="$disk_usage" \
        --button="OK:0" --button="Cancel:1" \
        --wrap \
        --scroll \
        --no-buttons
}

# monitorCpuUsage(){
    
#     clear
#     echo "**** CPU Usage ****"
#     echo "Monitoring CPU usage... Press 'q' and Enter to stop."
    
#     while true; do
#         cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
#         echo -ne "Current CPU Usage: $cpu_usage% \r"
#         sleep 1
#         if read -r -t 1 -n 1 input; then
#             if [[ "$input" == "q" ]]; then
#                 echo -e "\nStopping CPU usage monitoring."
#                 clear
#                 break
#             fi
#         fi
#     done
# }

monitor_cpu_usage() {
   (
        while true; do
            cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
            cpu_usage_int=$(printf "%.0f" "$cpu_usage") 
            echo "$cpu_usage_int"
            echo "# Current CPU Usage: $cpu_usage_int%"

            sleep 1
        done
    ) | yad --title="CPU Usage Monitoring" \
            --text="Monitoring CPU usage..." \
            --percentage=0 \
            --progress \
            --auto-close \
            --width=400 --height=150
}

# function system_information_display() {
#     echo "System Information"
#     echo "Operating System: $(uname -o)"
#     echo "Hostname: $(hostname)"
#     echo "Uptime: $(uptime -p)"
#     echo "Current Date/Time: $(date)"
# }

function system_information_display() {
    yad --title="System Information" \
        --text="Operating System: $(uname -o)\nHostname: $(hostname)\nUptime: $(uptime -p)\nCurrent Date/Time: $(date)" \
        --button=gtk-ok:0 --button=gtk-cancel:1 \
        --width=400 --height=200
}

# function display_memory_usage() {
#     MEMORY_STATS=$(free -h)

#     TOTAL_MEMORY=$(echo "$MEMORY_STATS" | awk '/Mem:/ {print $2}')
#     USED_MEMORY=$(echo "$MEMORY_STATS" | awk '/Mem:/ {print $3}')
#     FREE_MEMORY=$(echo "$MEMORY_STATS" | awk '/Mem:/ {print $4}')

#     echo "Memory Usage:"
#     echo "Total Memory: $TOTAL_MEMORY"
#     echo "Used Memory:  $USED_MEMORY"
#     echo "Free Memory:  $FREE_MEMORY"
# }

function display_memory_usage() {
    MEMORY_STATS=$(free -h)

    TOTAL_MEMORY=$(echo "$MEMORY_STATS" | awk '/Mem:/ {print $2}')
    USED_MEMORY=$(echo "$MEMORY_STATS" | awk '/Mem:/ {print $3}')
    FREE_MEMORY=$(echo "$MEMORY_STATS" | awk '/Mem:/ {print $4}')

    yad --form --title="Memory Usage" \
        --text="Memory Usage Information:\n\nTotal Memory: $TOTAL_MEMORY\nUsed Memory: $USED_MEMORY\nFree Memory: $FREE_MEMORY" \
        --button="OK":0 --button="Cancel":1 \
        --width=400 --height=200

    if [[ $? -eq 1 ]]; then
        echo "Operation cancelled."
    fi
}

function logging_and_report() {
    output_file=$(yad --file-selection --directory --title="Choose Directory" --text="Select the directory where you want to save the report:" --width=400 --height=150)

    # Check if Cancel button was pressed
    if [[ $? -eq 1 ]]; then
        echo "Operation cancelled."
        return
    fi
    echo $output_file
    # Append default report filename
    if [[ -d "$output_file" ]]; then
        output_file="${output_file}/report.txt"

        {
            echo "System Metrics Report - $(date)"
            echo "----------------------------------"
            echo "System Uptime:"
            uptime -p
            echo ""
            echo "Load Average (1, 5, 15 minutes):"
            uptime | awk -F'load average: ' '{ print $2 }'
            echo ""
            echo "CPU Usage (%):"
            top -bn1 | grep "Cpu(s)" | \
            sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
            awk '{print 100 - $1"%"}'
            echo ""
            echo "Memory Usage (%):"
            free | grep Mem | awk '{print $3/$2 * 100.0"%"}'
            echo ""
            echo "Disk Usage (%):"
            df -h | grep '^/dev/' | awk '{print $1 ": " $5}'
            echo ""
            echo "Network Activity (bytes):"
            echo "Sent: $(cat /proc/net/dev | grep eth0 | awk '{print $10}')"
            echo "Received: $(cat /proc/net/dev | grep eth0 | awk '{print $2}')"
            echo ""
            echo "Top 5 Memory-Consuming Processes:"
            ps aux --sort=-%mem | awk 'NR<=5{print $0}'
            echo ""
            echo "Top 5 CPU-Consuming Processes:"
            ps aux --sort=-%cpu | awk 'NR<=5{print $0}'
            echo ""
        } > "$output_file"

        yad --info --title="Report Saved" --text="Report saved successfully to $output_file" --width=300 --height=100
    else
        yad --error --title="Path Error" --text="The specified path does not exist. Exiting Logging and Report." --width=300 --height=100
    fi
}
