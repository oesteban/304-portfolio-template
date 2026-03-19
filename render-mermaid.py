#!/usr/bin/env python3
"""Pre-render mermaid code blocks in portfolio.yaml text fields.

Scans ``what``, ``why``, and ``reflection`` for ```mermaid ... ``` blocks,
renders each via the mermaid.ink API to PNG (browser-rendered, so text labels
are correct), strips the block from the text, and appends the rendered image
to the entry's ``figures`` list.

Writes the processed YAML to ``_portfolio.yaml`` for Typst to consume.
If no mermaid blocks are found, ``_portfolio.yaml`` is a verbatim copy.
"""

import base64
import hashlib
import json
import os
import re
import shutil
import sys
import zlib
from urllib.error import URLError
from urllib.request import Request, urlopen

import yaml

SRC = "portfolio.yaml"
DST = "_portfolio.yaml"
FIG_DIR = "figures"
MERMAID_RE = re.compile(r"```mermaid[ \t]*\n?(.*?)```", re.DOTALL)
TEXT_FIELDS = ("what", "why", "reflection")
MERMAID_INK = "https://mermaid.ink/img/pako:{encoded}?type=png&bgColor=white"


def render_diagram(code, out_path):
    """Render a mermaid diagram to PNG via mermaid.ink."""
    state = json.dumps({"code": code, "mermaid": {"theme": "default"}})
    compressed = zlib.compress(state.encode(), level=9)
    encoded = base64.urlsafe_b64encode(compressed).decode()
    url = MERMAID_INK.format(encoded=encoded)
    req = Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urlopen(req, timeout=60) as resp:
        data = resp.read()
    with open(out_path, "wb") as f:
        f.write(data)


def process_entries(entries):
    """Find and render mermaid blocks in entry text fields.

    Returns (modified_entries, n_rendered).
    """
    os.makedirs(FIG_DIR, exist_ok=True)
    n_rendered = 0

    for entry in entries:
        for field in TEXT_FIELDS:
            text = entry.get(field)
            if not text or not isinstance(text, str):
                continue
            matches = list(MERMAID_RE.finditer(text))
            if not matches:
                continue
            figs = list(entry.get("figures") or [])
            for match in matches:
                code = match.group(1)
                h = hashlib.sha1(code.encode()).hexdigest()[:12]
                fname = f"_mermaid_{h}.png"
                fpath = os.path.join(FIG_DIR, fname)
                if not os.path.exists(fpath):
                    try:
                        render_diagram(code, fpath)
                        n_rendered += 1
                        print(f"  Rendered {fname}")
                    except (URLError, OSError) as exc:
                        print(f"  Warning: failed to render mermaid block: {exc}")
                        continue
                figs.append({"path": f"figures/{fname}", "caption": ""})
            entry[field] = MERMAID_RE.sub("", text).strip()
            entry["figures"] = figs

    return entries, n_rendered


def main():
    src = sys.argv[1] if len(sys.argv) > 1 else SRC

    with open(src) as f:
        data = yaml.safe_load(f)

    entries = data.get("entries") or []

    # Check parsed values for mermaid blocks
    has_mermaid = any(
        isinstance(e.get(f), str) and MERMAID_RE.search(e[f])
        for e in entries
        for f in TEXT_FIELDS
    )

    if not has_mermaid:
        shutil.copy2(src, DST)
        print("No mermaid blocks found — copied as-is")
        return

    data["entries"], n = process_entries(entries)

    with open(DST, "w") as f:
        yaml.dump(data, allow_unicode=True, default_flow_style=False,
                  sort_keys=False, stream=f)
    print(f"Processed {n} mermaid block(s) → {DST}")


if __name__ == "__main__":
    main()
