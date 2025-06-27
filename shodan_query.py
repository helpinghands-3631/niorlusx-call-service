import os
import shodan
from dotenv import load_dotenv

# Load API key
load_dotenv()
SHODAN_API_KEY = os.getenv("SHODAN_API_KEY")

if not SHODAN_API_KEY:
    raise ValueError("SHODAN_API_KEY not found in .env file")

# Initialize Shodan API
api = shodan.Shodan(SHODAN_API_KEY)

# Ask for search input
query = input("[?] Enter Shodan search query (e.g. apache, port:22, country:AU): ").strip()

try:
    print(f"\n[+] Searching for: {query}")
    results = api.search(query)
    print(f"[✓] {results['total']} results found\n")

    for result in results['matches'][:10]:
        print("IP:     ", result.get('ip_str', 'N/A'))
        print("Port:   ", result.get('port', 'N/A'))
        print("Org:    ", result.get('org', 'N/A'))
        print("Banner: ", result.get('data', '')[:100].strip(), "...")
        print("-" * 60)

except shodan.APIError as e:
    print(f"[!] Shodan error: {e}")
