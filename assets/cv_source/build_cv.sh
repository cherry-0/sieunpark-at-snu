#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
assets_dir="$(cd -- "$script_dir/.." && pwd)"
source_file="$script_dir/resume_2026.tex"
output_file="$assets_dir/CV_2026_Sieun.pdf"
build_dir="$(mktemp -d "${TMPDIR:-/tmp}/sieun-cv-build.XXXXXX")"
staged_output="$assets_dir/.CV_2026_Sieun.pdf.tmp.$$"

cleanup() {
  rm -rf -- "$build_dir"
  rm -f -- "$staged_output"
}
trap cleanup EXIT

if ! command -v latexmk >/dev/null 2>&1; then
  echo "Error: latexmk is not installed or not available in PATH." >&2
  exit 1
fi

if [[ ! -f "$source_file" ]]; then
  echo "Error: CV source not found: $source_file" >&2
  exit 1
fi

echo "Building $source_file ..."
(
  cd -- "$script_dir"
  latexmk \
    -xelatex \
    -interaction=nonstopmode \
    -halt-on-error \
    -outdir="$build_dir" \
    "$(basename -- "$source_file")"
)

if [[ ! -s "$build_dir/resume_2026.pdf" ]]; then
  echo "Error: LaTeX completed without producing a non-empty PDF." >&2
  exit 1
fi

install -m 0644 "$build_dir/resume_2026.pdf" "$staged_output"
mv -f -- "$staged_output" "$output_file"

echo "CV updated: $output_file"
