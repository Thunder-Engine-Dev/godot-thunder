# godot-thunder

Patch set for Godot used by Thunder Engine. No Godot fork: upstream is cloned in CI, `patches/` is applied on top, and editors (Linux/Windows) plus export templates (Linux/Windows/Android) are built.

## Layout

- `patches/NNNN-feature/*.patch` — one directory per feature, applied in lexical order with `git apply`. Diffs are against upstream Godot.
  - `0001-opus-audio` — Opus audio module (`AudioStreamOpus`, libopus/libopusfile in thirdparty).
  - `0002-pixel-snap-2d` — 2D pixel-snap modes (`snap_2d_transforms_mode`, screen-space snapping, GPU particles).
- `scripts/prepare-source.sh <ref> <dir>` — clone upstream + apply patches (use locally too).
- `.github/workflows/build.yml` — build and release.

## Releasing

Actions → *Build Thunder Godot* → Run workflow. Pick the branch of this repo with the patches ("Use workflow from"), then set:

- `version` — release name, e.g. `4.7.3-rc2`. The part before `-` must match upstream `version.py` (checked), the part after becomes `GODOT_VERSION_STATUS` (version string `4.7.3.rc2`, build name is a separate suffix). It is also the default release tag.
- `godot_ref` — upstream branch, tag or full commit SHA. A branch (`4.7`) means its latest commit; it is resolved once and every job builds that exact commit (shown in the release notes).
- `build_name` — build name baked into the editor/templates (default `thunder`, shown in the About dialog; templates are looked up without it)
- `publish` — create a GitHub release (editor zips, `.tpz` export templates, SHA512 sums)

Builds mirror godotengine/build-containers + godot-build-scripts (no signing): `fedora:43` container, Linux via the Godot buildroot SDK, Windows via MinGW GCC (`use_mingw=yes`, D3D12, ANGLE, Mesa/NIR, AccessKit), Android via the SDK/NDK + Gradle template packaging (`swappy=yes`), flags `production=yes`. Dependency versions are pinned in the workflow `env` from the matching branch (e.g. `4.7`) of those repos; update them when moving to a new Godot branch. Targets: Linux and Windows x86_64, editor + debug/release templates; Android arm32/arm64/x86_32/x86_64 debug/release templates (no editor). No Mono.

## Adding / updating patches

```bash
scripts/prepare-source.sh 4.7 /tmp/godot && cd /tmp/godot
# edit, then:
git diff --binary --full-index HEAD~1 > ~/Projects/godot-thunder/patches/NNNN-name/0001-name.patch
```

When a new upstream version breaks a patch, rebase the change in a checkout of that version and regenerate the patch on the matching branch of this repo.
