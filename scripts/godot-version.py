#!/usr/bin/env python3
"""Print the export templates version (version.txt), e.g. 4.7.3.rc2 (no build name).

Usage: godot-version.py <godot_dir> <version>

<version> is the release name such as "4.7.3-rc2" or "4.7.2-stable": the part
before "-" must match major.minor[.patch] of the checked-out version.py, the
part after it becomes the version status (GODOT_VERSION_STATUS).
"""
import re
import sys

src = open(f"{sys.argv[1]}/version.py").read()
release = sys.argv[2]


def field(name):
    return re.search(rf'^{name}\s*=\s*"?([^"\n]+)"?', src, re.M).group(1)


parts = [field("major"), field("minor")]
if field("patch") != "0":  # Godot omits a zero patch level
    parts.append(field("patch"))
base = ".".join(parts)

num, _, status = release.partition("-")
if not status:
    sys.exit(f"version '{release}' must look like 4.7.3-rc2")
if num.removesuffix(".0") != base and num != base:
    sys.exit(f"version '{release}' does not match upstream version.py ({base})")
print(f"{base}.{status}")
print(status, file=sys.stderr)
