#!/usr/bin/env bash
# Local pre-publish pipeline for the Jekyll site.
# Builds the site, runs HTML validation against _site/, and optionally serves
# the result for a final visual review. Purely additive: never edits source files.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SITE_DIR="${REPO_ROOT}/_site"
CHECK_SCRIPT="${REPO_ROOT}/_scripts/check_html.rb"

SERVE=0
SKIP_BUILD=0
STRICT=0

usage() {
    cat <<'EOF'
Usage: scripts/precheck.sh [options]

Options:
  --serve         After checks pass, run `bundle exec jekyll serve` for visual review.
  --skip-build    Reuse the existing _site/ output instead of rebuilding.
  --strict        Treat warnings (TODO/FIXME, Liquid leakage) as failures.
  -h, --help      Show this help.

Pipeline steps:
  1. jekyll build (JEKYLL_ENV=production)
  2. presence check for expected output pages
  3. HTML validation via scripts/check_html.rb
  4. (optional) jekyll serve for browser review
EOF
}

for arg in "$@"; do
    case "$arg" in
        --serve)      SERVE=1 ;;
        --skip-build) SKIP_BUILD=1 ;;
        --strict)     STRICT=1 ;;
        -h|--help)    usage; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; usage; exit 2 ;;
    esac
done

step() { printf "\n\033[1;34m==>\033[0m %s\n" "$*"; }
ok()   { printf "  \033[1;32mok\033[0m %s\n" "$*"; }
warn() { printf "  \033[1;33mwarn\033[0m %s\n" "$*"; }
fail() { printf "  \033[1;31mfail\033[0m %s\n" "$*"; }

cd "$REPO_ROOT"

# --- step 1: build --------------------------------------------------------
if [ "$SKIP_BUILD" -eq 0 ]; then
    step "Building site (JEKYLL_ENV=production)"
    if ! command -v bundle >/dev/null 2>&1; then
        fail "bundler not found — install Ruby + run 'gem install bundler'"
        exit 1
    fi
    if [ ! -f Gemfile.lock ]; then
        warn "Gemfile.lock missing; running 'bundle install' first"
        bundle install || { fail "bundle install failed"; exit 1; }
    fi
    # github-pages plugin needs to know the owner/repo. Derive it from the
    # configured `origin` remote if PAGES_REPO_NWO isn't already in the env.
    if [ -z "${PAGES_REPO_NWO:-}" ]; then
        if remote_url="$(git config --get remote.origin.url 2>/dev/null)"; then
            nwo="$(echo "$remote_url" \
                | sed -E 's#^(https?://[^/]+/|git@[^:]+:)##; s#\.git$##')"
            if [ -n "$nwo" ]; then
                export PAGES_REPO_NWO="$nwo"
                ok "detected PAGES_REPO_NWO=$PAGES_REPO_NWO"
            fi
        fi
    fi
    JEKYLL_ENV=production bundle exec jekyll build --trace || {
        fail "jekyll build failed"
        exit 1
    }
    ok "build complete -> $SITE_DIR"
else
    step "Skipping build (--skip-build); using existing $SITE_DIR"
    [ -d "$SITE_DIR" ] || { fail "_site/ does not exist; remove --skip-build"; exit 1; }
fi

# --- step 2: presence check ----------------------------------------------
step "Checking expected output pages"
EXPECTED=(
    "index.html"
    "about/index.html"
    "publications/index.html"
    "interests/index.html"
    "404.html"
    "feed.xml"
    "assets/CV_2026_Sieun.pdf"
    "assets/images/profile.jpg"
)
missing=0
for rel in "${EXPECTED[@]}"; do
    if [ -e "${SITE_DIR}/${rel}" ]; then
        ok "found ${rel}"
    else
        fail "missing ${rel}"
        missing=$((missing + 1))
    fi
done
if [ "$missing" -gt 0 ]; then
    fail "$missing expected file(s) missing from _site/"
    exit 1
fi

# --- step 3: html validation ---------------------------------------------
step "Validating HTML in _site/"
if ! command -v ruby >/dev/null 2>&1; then
    fail "ruby not found; cannot run HTML validation"
    exit 1
fi

CHECK_ARGS=("$SITE_DIR")
[ "$STRICT" -eq 1 ] && CHECK_ARGS+=("--strict")

ruby "$CHECK_SCRIPT" "${CHECK_ARGS[@]}"
CHECK_RC=$?
if [ "$CHECK_RC" -ne 0 ]; then
    fail "HTML validation failed (exit $CHECK_RC)"
    exit "$CHECK_RC"
fi
ok "HTML validation passed"

# --- step 4: optional serve ----------------------------------------------
if [ "$SERVE" -eq 1 ]; then
    step "Starting local server (Ctrl-C to stop)"
    # Offline / no-API runs of github-pages plugin compute a phantom baseurl
    # (e.g. /pages/<user>/<repo>), so generated links 404 against the flat
    # _site/ layout. Force baseurl="" for the preview so /about/ etc. resolve.
    warn "rebuilding with --baseurl '' for local preview (production baseurl unchanged)"
    exec bundle exec jekyll serve --baseurl ""
fi

step "Precheck complete — safe to publish"
