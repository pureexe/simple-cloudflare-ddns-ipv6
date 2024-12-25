#!/bin/bash

# Cloudflare API credentials
CF_API_TOKEN="YOUR_API_TOKEN"
CF_ZONE_ID="YOUR_ZONE_ID"

# Array of domains to manage
domains=('YOUR_SUBDOMAIN_1' 'YOUR_SUBDOMAIN_2')

# Function to get the current public IPv6 of the machine
get_public_ipv6() {
    ip -6 addr show dev eth0 | grep "inet6" | grep -v "fe80::" | grep -v "temporary" | awk '{print $2}' | cut -d/ -f1 | head -n 1
}

# Function to get the Cloudflare DNS record details
get_cloudflare_dns_record() {
    local domain=$1
    curl -s -X GET \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json" \
        "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records?name=$domain&type=e"
}

# Function to update the Cloudflare DNS record
update_cloudflare_dns_record() {
    local record_id=$1
    local domain=$2
    local new_ip=$3

    curl -s -X PUT \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"AAAA\",\"name\":\"$domain\",\"content\":\"$new_ip\",\"ttl\":1,\"proxied\":true}" \
        "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$record_id"
}

# Main script logic
public_ipv6=$(get_public_ipv6)
echo "Public IPv6: $public_ipv6"

for domain in "${domains[@]}"; do
    echo "Processing domain: $domain"

    # Get Cloudflare DNS record details
    response=$(get_cloudflare_dns_record "$domain")
    record_id=$(echo "$response" | jq -r '.result[0].id')
    cloudflare_ip=$(echo "$response" | jq -r '.result[0].content')

    if [ -z "$record_id" ] || [ -z "$cloudflare_ip" ]; then
        echo "Failed to retrieve DNS record for $domain. Skipping..."
        continue
    fi

    echo "Cloudflare IPv6: $cloudflare_ip"

    # Compare IPs
    if [ "$cloudflare_ip" == "$public_ipv6" ]; then
        echo "IP addresses match. No update needed for $domain."
    else
        echo "IP addresses do not match. Updating $domain..."
        update_response=$(update_cloudflare_dns_record "$record_id" "$domain" "$public_ipv6")
        success=$(echo "$update_response" | jq -r '.success')

        if [ "$success" == "true" ]; then
            echo "Successfully updated $domain to $public_ipv6."
        else
            echo "Failed to update $domain. Response: $update_response"
        fi
    fi
    echo "------------------------------------------------"
done
