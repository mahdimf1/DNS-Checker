#!/bin/bash

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
}

# Function to install and configure a cron job
install_cron_job() {
    local cron_hour="$1"

    # Script path and content
    SCRIPT_PATH="/usr/local/bin/check_dns.sh"
    echo -e "#!/bin/bash
echo -e \"$EXPECTED_DNS\" | sudo tee /etc/resolv.conf > /dev/null
echo \"Updated DNS settings.\"
" > "$SCRIPT_PATH"

    chmod +x "$SCRIPT_PATH"

    # Add cron job
    (crontab -l 2>/dev/null; echo "0 $cron_hour * * * $SCRIPT_PATH") | crontab -
}

# Prompt for DNS servers
set_dns_servers

# Prompt user for cron scheduling hour
echo "Please enter the hour (0-23) to run the script daily:"
read cron_hour

# Validate the input
while ! [[ "$cron_hour" =~ ^[0-9]+$ ]] || [ "$cron_hour" -lt 0 ] || [ "$cron_hour" -gt 23 ]; do
    echo "Invalid input. Please enter a valid hour (0-23):"
    read cron_hour
done

# Execute the function to install cron job
install_cron_job "$cron_hour"

echo "Installation and configuration completed."
