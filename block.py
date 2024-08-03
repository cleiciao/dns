import requests
import os

RPZ_ZONE_PATH = '/etc/unbound/unbound.conf.d/rpz.local.zone'
CLOUD_URL = 'https://raw.githubusercontent.com/cleiciao/dns/main/blacklist'

def download_cloud_list(url):
    response = requests.get(url)
    response.raise_for_status()
    return response.text.splitlines()

def read_local_list(file_path):
    if os.path.exists(file_path):
        with open(file_path, 'r') as file:
            return file.read().splitlines()
    return []

def write_local_list(file_path, domains):
    with open(file_path, 'w') as file:
        file.write("\n".join(domains))

def generate_rpz_zone(domains):
    rpz_zone_content = [
        "$TTL 2h",
        "@       IN      SOA     localhost. root.localhost. (",
        "                          1        ; Serial",
        "                          1h       ; Refresh",
        "                          15m      ; Retry",
        "                          30d      ; Expire",
        "                          2h       ; Minimum TTL",
        "                        )",
        "        IN      NS      localhost.",
        ""
    ]
    
    for domain in domains:
        rpz_zone_content.append(f"{domain}    CNAME   .")
    
    return "\n".join(rpz_zone_content)

def update_rpz_zone():
    cloud_domains = download_cloud_list(CLOUD_URL)
    local_domains = read_local_list(RPZ_ZONE_PATH)
    
    if set(cloud_domains) != set(local_domains):
        rpz_zone_content = generate_rpz_zone(cloud_domains)
        
        with open(RPZ_ZONE_PATH, 'w') as zone_file:
            zone_file.write(rpz_zone_content)
        
        write_local_list(RPZ_ZONE_PATH, cloud_domains)
        os.system('unbound-control reload')

if __name__ == "__main__":
    update_rpz_zone()
