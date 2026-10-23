#!/usr/bin/env bash
# Usage: prepare-source.sh <godot_ref> <dest_dir>
# Clones upstream Godot at <godot_ref> (branch, tag or full commit SHA) and applies every patch
# in patches/*/ in lexical order. Fails if any patch does not apply cleanly.
set -euo pipefail

ref="${1:?godot ref (branch or tag) required}"
dest="${2:?destination dir required}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
upstream="${GODOT_REPO:-https://github.com/godotengine/godot.git}"

if [[ ! -d "$dest/.git" ]]; then
	if [[ "$ref" =~ ^[0-9a-f]{40}$ ]]; then
		git init -q "$dest"
		git -C "$dest" fetch -q --depth 1 "$upstream" "$ref"
		git -C "$dest" checkout -q FETCH_HEAD
	else
		git clone -q --depth 1 --branch "$ref" "$upstream" "$dest"
	fi
fi
echo "upstream commit: $(git -C "$dest" rev-parse HEAD)"

cd "$dest"
git config user.name  "thunder-patcher"
git config user.email "thunder-patcher@users.noreply.github.com"

shopt -s nullglob
for patch in "$root"/patches/*/*.patch; do
	echo ">> applying ${patch#"$root"/}"
	git apply --index --whitespace=nowarn "$patch"
done
git commit -q -m "Thunder patches" || true
