#!/usr/bin/env python3
"""Check evidence URLs in portfolio.yaml and write broken_links.yaml."""
import os
import re
import subprocess
import sys


def load_allowlist(path):
    """Load known-good URL patterns from a YAML list file.

    Entries ending with ``*`` are treated as prefixes; others must match exactly.
    """
    prefixes, exact = [], set()
    if not os.path.isfile(path):
        return prefixes, exact
    with open(path) as f:
        for line in f:
            line = line.strip().strip("-").strip()
            if not line or line.startswith("#"):
                continue
            url = line.strip('"').strip("'")
            if url.endswith("*"):
                prefixes.append(url[:-1])
            else:
                exact.add(url)
    return prefixes, exact


def is_allowed(url, prefixes, exact):
    if url in exact:
        return True
    return any(url.startswith(p) for p in prefixes)


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
    allowlist = os.path.join(os.path.dirname(path), "..", "known_urls.yaml")
    prefixes, exact = load_allowlist(allowlist)

    urls = extract_urls(path)
    skipped = [url for url in urls if is_allowed(url, prefixes, exact)]
    to_check = [url for url in urls if not is_allowed(url, prefixes, exact)]
    broken = [url for url in to_check if not check_url(url)]

    with open("broken_links.yaml", "w") as f:
        if broken:
            for url in broken:
                f.write(f'- "{url}"\n')
        else:
            f.write("[]\n")

    if skipped:
        print(f"Skipped {len(skipped)} allowlisted URL(s)")
    if broken:
        print(f"{len(broken)} broken link(s):")
        for url in broken:
            print(f"  - {url}")
        sys.exit(1)
    else:
        print(f"All {len(to_check)} checked links OK")


if __name__ == "__main__":
    main()
