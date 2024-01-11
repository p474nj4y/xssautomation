#!/bin/bash
# Tool Required : 
# SubFinder, AssetFinder, httpx, ParamSpider, Kxss
# Get domain input from the user
read -p "Enter the domain: " domain
mkdir ~/$domain
touch ~/$domain/subfinder-subdomains.txt
touch ~/$domain/assetfinder-subdomains.txt
touch ~/$domain/subdomains.txt
touch ~/$domain/sort.txt
touch ~/$domain/200_urls.txt
touch ~/$domain/filtered_urls.txt

# Set file paths
subfinderOutput="~/$domain/subfinder-subdomains.txt"
assetfinderOutput="~/$domain/assetfinder-subdomains.txt"
combinedSubdomains="~/$domain/subdomains.txt"
sortedSubdomains="~/$domain/sort.txt"
httpxOutput="~/$domain/200_urls.txt"
paramspiderOutput="~/$domain/filtered_urls.txt"

# Run subfinder
subfinder -d "$domain" -o "$subfinderOutput"

# Run assetfinder
assetfinder --subs-only "$domain" > "$assetfinderOutput"

# Combine subdomains from subfinder and assetfinder
cat "$subfinderOutput" "$assetfinderOutput" > "$combinedSubdomains"

# Remove duplicate subdomains and sort
sort -u "$combinedSubdomains" > "$sortedSubdomains"

# Run httpx to filter URLs with HTTP status 200
cat "$sortedSubdomains" | httpx -mc 200 > "$httpxOutput"

# Run paramspider on filtered URLs
while IFS= read -r URL; do
    python3 ~/ParamSpider/paramspider.py -d "${URL}"
done < "$httpxOutput"

# Run kxss on filtered URLs
cat "$paramspiderOutput" | kxss
