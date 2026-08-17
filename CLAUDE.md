---
published: false
sitemap: false
layout: null
permalink: none
---
{% raw %}
# CLAUDE.md

Project guide for Claude Code working in this repository.

## What this repo is

Personal academic site for **Sieun Park** (MS/PhD, SNU HCS Lab), built on a fork of the
[Indigo](https://github.com/sergiokopplin/indigo) Jekyll theme. Deployed to GitHub Pages
from the `gh-pages` branch at `https://cherry-0.github.io/sieunpark-at-snu`.

Content focus: research interests, publications, about, and CV (PDF in `assets/`).

## Stack

- **Static site generator**: Jekyll (via `github-pages` gem — pinned versions)
- **Templating**: Liquid (`_layouts/`, `_includes/`)
- **Styling**: Sass partials under `_sass/` (compiled inline in `_layouts/default.html`)
- **Plugins**: `jekyll-seo-tag`, `jekyll-gist`, `jekyll-feed`, `jemoji`
- **Runtime**: Ruby + Bundler (or Docker via `docker-compose.yml`)
- **Hosting**: GitHub Pages (branch `gh-pages`, which is also the working branch)

## Directory map

```
_config.yml          site config (author, nav toggles, plugins, theme)
_layouts/            default.html, page.html, post.html, compress.html
_includes/           header, nav, footer, favicon, social, dark/light SCSS
_sass/               base/, components/, pages/ partials
_posts/              blog/project markdown posts (date-prefixed)
assets/              CV PDF, profile/screenshot images
about.md             about page
interests.md / .html research interests page
publications.md / .html  publications list
projects.html        projects index (driven by _posts with `projects: true`)
blog.html            blog index
tags.html            tag index
index.html           home (uses page layout)
404.html             error page
_site/               build output (gitignored)
_scripts/             local pre-publish checks (see below)
```

Note: both `interests.md` and `interests.html` (same for `publications`) exist. The `.md`
file is the canonical content; the `.html` file is a Liquid loop view. Treat them as
intentional siblings — do not delete one when editing the other.

## Local development

Native Ruby:
```sh
bundle install
bundle exec jekyll serve   # http://localhost:4000
```

Docker:
```sh
docker-compose up
```

## Pre-publish check pipeline

Before pushing to `gh-pages`, run the local check pipeline to build the site and verify the
generated HTML:

```sh
./_scripts/precheck.sh
```

What it does (all additive — does not modify source files):
1. Builds the site with `JEKYLL_ENV=production bundle exec jekyll build`.
2. Verifies that expected pages exist in `_site/` (home, about, publications, interests, CV).
3. Validates generated HTML via `_scripts/check_html.rb` (Ruby stdlib only — no extra gems):
   - missing local assets / broken relative links
   - empty `<title>` / missing `<meta charset>`
   - unresolved Liquid (`{{ ... }}` / `{% ... %}`) leaking into output
   - dangling `TODO` / `FIXME` markers
4. Optional: launches `bundle exec jekyll serve` so you can eyeball the result in a browser.

Run `./_scripts/precheck.sh --serve` to chain the visual review step.
Run `./_scripts/precheck.sh --help` for all options.

## Editing conventions

- Site config lives in `_config.yml` — name, bio, social handles, nav toggles.
- Profile picture path: `assets/images/profile.jpg`. CV path: `assets/CV_2025_Sieun.pdf`
  (also referenced in `_config.yml` as `resume-url`).
- URLs in templates use `| relative_url` (see `_includes/nav.html`) so the site works under
  the `/sieunpark-at-snu` project path on GitHub Pages. Prefer `relative_url` for any new
  internal link.
- Dark/light theme is `auto` (system-driven) per `_config.yml`. Styling forks at
  `_includes/style.scss` vs `_includes/style-dark.scss`.
- Posts under `_posts/` with front-matter `projects: true` show up on the Projects page
  and the Interests index loop.

## Things not to do

- Don't commit `_site/`, `Gemfile.lock`, `.sass-cache`, or `vendor/` (already in
  `.gitignore`).
- Don't change `url:` in `_config.yml` without coordinating — it's the canonical GitHub
  Pages URL and feeds SEO + RSS.
- Don't delete `interests.html` / `publications.html` as duplicates of the `.md` files —
  they serve different roles.
- Don't bypass the precheck before publishing if you changed templates, `_config.yml`, or
  added pages.
{% endraw %}
