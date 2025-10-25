#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import requests
import json
import re # <-- NEW: Import 're' for regular expressions

# Define ANSI escape codes for coloring terminal output
BLUE = '\033[94m'
RESET = '\033[0m'
BOLD = '\033[1m'

# Define box-drawing characters
TL = '┌' # Top-Left corner
TR = '┐' # Top-Right corner
BL = '└' # Bottom-Left corner
BR = '┘' # Bottom-Right corner
H = '─'  # Horizontal line
V = '│'  # Vertical line

# Helper function to remove ANSI codes for accurate width calculation
def strip_ansi(text):
    return re.sub(r'\x1b\[[0-9;]*m', '', text)

def ip_lookup(ip_address=''):
    """
    Performs an IP geolocation lookup using ipinfo.io and prints the results
    inside a colored box using Unicode characters.
    """
    # ipinfo.io is a simple service for geolocation lookups
    url = f"https://ipinfo.io/{ip_address}/json"

    try:
        print(f"Querying IP Geolocation for: {ip_address if ip_address else 'Self/Public IP'}...")

        response = requests.get(url, timeout=5)
        response.raise_for_status() # Raise HTTPError for bad responses (4xx or 5xx)
        data = response.json()

        if 'error' in data:
            print(f"API Error: {data['error'].get('title', 'Unknown Error')}")
            return

        # Prepare data lines for uniform spacing
        ip = data.get('ip', 'N/A')
        city = data.get('city', 'N/A')
        region = data.get('region', 'N/A')
        country = data.get('country', 'N/A')
        isp = data.get('org', 'N/A')
        timezone = data.get('timezone', 'N/A')
        
        # Format the result lines with ANSI codes
        lines = [
            f"{BOLD}IP Address:{RESET} {ip}",
            f"{BOLD}Country:{RESET}    {country}",
            f"{BOLD}Area:{RESET}       {city}, {region}",
            f"{BOLD}ISP:{RESET}        {isp}",
            f"{BOLD}Timezone:{RESET}   {timezone}"
        ]

        # Calculate the maximum width for the box using the new strip_ansi function
        max_width = max(len(strip_ansi(line)) for line in lines)
        box_width = max_width + 4 # Padding for 2 spaces on each side

        # Draw the blue box
        print(f"\n{BLUE}{TL}{H * box_width}{TR}{RESET}")
        
        for line in lines:
            # Calculate necessary spaces to fill the box width
            content_length = len(strip_ansi(line)) # Use stripped length for padding
            padding = box_width - content_length - 2 # 2 is for the spaces inside the box
            
            print(f"{BLUE}{V}{RESET}  {line}{' ' * padding} {BLUE}{V}{RESET}")

        print(f"{BLUE}{BL}{H * box_width}{BR}{RESET}")

    except requests.exceptions.HTTPError as errh:
        print(f"HTTP Error occurred: {errh}")
        print("The IP address may be invalid or the API is unreachable.")
    except requests.exceptions.RequestException as err:
        print(f"An unexpected connection error occurred: {err}")
        print("Please check your internet connection or the API service status.")
    except json.JSONDecodeError:
        print("Error: Could not decode JSON response from API. Response format may be unexpected.")
    except Exception as e:
        print(f"An unknown error occurred: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        ip_address = sys.argv[1]
    else:
        ip_address = ''

    ip_lookup(ip_address)
