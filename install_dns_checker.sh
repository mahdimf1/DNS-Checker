#!/bin/bash

# Function to display current DNS settings
display_current_dns() {
    echo "Current DNS settings:"
    cat /etc/resolv.conf | grep "nameserver"
    echo
}

# Function to prompt for and set DNS servers
set_dns_servers() {
    echo "Please enter the DNS servers you wish to use, separated by spaces (e.g., '8.8.8.8 8.8.4.4 1.1.1.1'):"
    read -a dns_array

    # Construct the EXPECTED_DNS variable from user input
    EXPECTED_DNS=""
    for dns in "${dns_array[@]}"; do
        EXPECTED_DNS+="nameserver $dns\n"
    done

    # Update the DNS settings immediately
    echo -e "$EXPECTED_DNS" | sudo tee /etc/resolv.conf > /dev/null
    echo "DNS settings updated."

    # Restart the resolvconf service to apply changes
    sudo systemctl restart resolvconf
    echo "resolvconf service restarted to apply DNS settings."
}

# Function to install DNS tools
install_dns_tools() {
    echo "Installing and configuring DNS tools..."
    sudo apt-get update -y && sudo apt-get upgrade -y
    sudo apt install resolvconf -y
    sudo systemctl enable resolvconf
    sudo systemctl restart resolvconf
    echo "DNS tools installed and configured."
}

# Function to display current cron jobs
display_cron_jobs() {
    echo "Current scheduled cron jobs:"
    crontab -l
}

# Function to delete a cron job
delete_cron_job() {
    echo "Enter the line number of the cron job you wish to delete:"
    crontab -l
    echo "---------------------------------------------"
    read line_num
    # Delete the specific cron job
    crontab -l | sed "${line_num}d" | crontab -
    echo "Cron job deleted."
}

# Function to clear the screen and show the menu
show_menu() {
    clear
    echo "Starting DNS Configuration Script"
    display_current_dns

    echo "Select an option:"
    echo "1. Install DNS Tools"
    echo "2. Set DNS Servers"
    echo "3. Delete a Cron Job"
    echo "0. Exit"
    read -p "Choice: " choice
}

# Main script execution loop
while true; do
    show_menu
    case "$choice" in
        1) install_dns_tools ;;
        2) set_dns_servers ;;
        3) delete_cron_job ;;
        0) echo "Exiting script."; break ;;
        *) echo "Invalid option. Please try again." ;;
    esac
    echo
done
