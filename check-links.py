#!/usr/bin/env python3
"""Check evidence URLs in portfolio.yaml and write broken_links.yaml."""
import re
import subprocess
import sys


def extract_urls(path="portfolio.yaml"):
    urls = set()
    with open(path) as f:
        for match in re.finditer(r'url:\s*["\']?([^"\'#\s]+)', f.read()):
            candidate = match.group(1)
            if candidate.startswith(("http://", "https://")):
                urls.add(candidate)
    return sorted(urls)


def check_url(url):
    cmd = [
        "curl", "-o", "/dev/null", "-s", "-w", "%{http_code}",
        "-L", "--max-time", "10",
    ]
    cmd.append(url)
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=15)
        code = result.stdout.strip()
        return code.startswith("2") or code.startswith("3")
    except Exception:
        return False


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "portfolio.yaml"
    urls = extract_urls(path)
    broken = [url for url in urls if not check_url(url)]

    with open("broken_links.yaml", "w") as f:
        if broken:
            for url in broken:
                f.write(f'- "{url}"\n')
        else:
            f.write("[]\n")

    if broken:
        print(f"{len(broken)} broken link(s):")
        for url in broken:
            print(f"  - {url}")
        sys.exit(1)
    else:
        print(f"All {len(urls)} links OK")


if __name__ == "__main__":
    main()
