"""Convert local file paths to GitHub blob URLs when running in CI."""

import os
import sys

import yaml


def main():

    # Load the different needed env variables
    github_server = os.environ.get("GITHUB_SERVER_URL", "")
    github_repo = os.environ.get("GITHUB_REPOSITORY", "")
    github_sha = os.environ.get("GITHUB_SHA", "")

    # Do nothing if any of the variable isn't set
    if not github_server or not github_repo or not github_sha:
        print("Not in CI environment, skipping path conversion")
        sys.exit(0)

    # Load the pixi _portfolio.yaml artifact
    with open("_portfolio.yaml") as f:
        portfolio = yaml.safe_load(f)

    # Generate the github base url
    base_url = f"{github_server}/{github_repo}/blob/{github_sha}"
    converted = 0

    for entry in portfolio.get("entries", []):
        # Convert evidence paths to URLs
        for ev in entry.get("evidence", []):

            # Convert the path to an url
            if "path" in ev and "url" not in ev:
                ev["url"] = f"{base_url}/{ev['path']}"
                del ev["path"]
                converted += 1

    # Write back the converted _portfolio.yaml
    with open("_portfolio.yaml", "w") as f:
        yaml.safe_dump(portfolio, f, sort_keys=False, allow_unicode=True)

    print(f"Converted {converted} path(s) to GitHub URLs")


if __name__ == "__main__":
    main()
