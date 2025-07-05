
#!/usr/bin/env python3

import sys
import os
import re
import unicodedata

def normalize_filename(path):
    directory, original = os.path.split(path)

    normalized = unicodedata.normalize('NFKD', original)
    normalized = normalized.lower()
    normalized = re.sub(r"[ _]+", "-", normalized)
    normalized = re.sub(r"[^a-z0-9.\-]", "", normalized)
    normalized = re.sub(r"-{2,}", "-", normalized)
    normalized = normalized.strip("-")

    if normalized == original:
        return

    new_path = os.path.join(directory, normalized)

    if os.path.exists(new_path):
        print(f"Skipping: {new_path} already exists")
        return

    os.rename(path, new_path)
    print(f"Renamed:\n  {original}\n  -> {normalized}")

if __name__ == "__main__":
    for filepath in sys.argv[1:]:
        normalize_filename(filepath)
