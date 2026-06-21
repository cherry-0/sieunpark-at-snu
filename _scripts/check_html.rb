#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Lightweight HTML validator for the Jekyll output under _site/.
# Uses only the Ruby stdlib so it has no extra gem dependencies.
#
# Checks performed:
#   - every HTML file has a non-empty <title> and a <meta charset>
#   - relative <a href> / <link href> / <img src> / <script src> targets
#     resolve to a real file inside _site/
#   - unresolved Liquid markers ({{ ... }} or {% ... %}) didn't leak through
#   - TODO / FIXME markers in rendered HTML (warn unless --strict)
#
# Errors fail the run (exit 1). Warnings only fail when --strict is given.

require "find"
require "uri"
require "set"
require "cgi"

SITE_DIR = ARGV.find { |a| !a.start_with?("--") } || "_site"
STRICT   = ARGV.include?("--strict")

unless Dir.exist?(SITE_DIR)
    warn "check_html: site directory not found: #{SITE_DIR}"
    exit 2
end

ROOT = File.expand_path(SITE_DIR)

errors   = []
warnings = []

def each_html(root)
    Find.find(root) do |path|
        next unless File.file?(path)
        next unless path.downcase.end_with?(".html", ".htm")
        yield path
    end
end

# Build a fast lookup of every file path that exists under _site/.
existing = Set.new
Find.find(ROOT) do |path|
    next unless File.file?(path)
    existing << File.expand_path(path)
end

# Hosts we always treat as "external" (no need to resolve locally).
EXTERNAL_RE = %r{\A(?:[a-z][a-z0-9+.\-]*:|//|mailto:|tel:|data:|javascript:|\#)}i

ATTR_RE = {
    "a"      => "href",
    "link"   => "href",
    "img"    => "src",
    "script" => "src",
    "source" => "src",
    "iframe" => "src",
}.freeze

def extract_refs(html)
    refs = []
    ATTR_RE.each do |tag, attr|
        html.scan(/<#{tag}\b[^>]*\b#{attr}\s*=\s*("([^"]*)"|'([^']*)')/i) do |m|
            value = m[1] || m[2]
            refs << [tag, attr, value] unless value.nil? || value.empty?
        end
    end
    refs
end

def resolve_local(href, page_path, root)
    return nil if href =~ EXTERNAL_RE

    # Strip query / fragment.
    target = href.split("#", 2).first.to_s.split("?", 2).first.to_s
    return nil if target.empty?

    target = CGI.unescape(target)

    if target.start_with?("/")
        # Site-absolute path. Jekyll prepends a baseurl that differs between
        # local builds (github-pages plugin -> /pages/<user>/<repo>/...) and
        # production (configured site.baseurl). Resolve by progressively
        # stripping leading segments until something maps inside _site/.
        clean = target.sub(%r{\A/+}, "")
        segments = clean.split("/")
        candidates = (0..segments.length).map do |i|
            File.join(root, segments[i..].join("/"))
        end
        candidates
    else
        [File.expand_path(target, File.dirname(page_path))]
    end
end

def candidate_exists?(candidates, existing)
    candidates.any? do |c|
        next true if existing.include?(File.expand_path(c))
        # directory-style links -> /foo/ should resolve to /foo/index.html
        idx = File.join(c, "index.html")
        next true if existing.include?(File.expand_path(idx))
        false
    end
end

each_html(ROOT) do |path|
    rel = path.sub("#{ROOT}/", "")
    html = File.read(path, encoding: "UTF-8", invalid: :replace, undef: :replace)

    # --- structural checks ---
    title = html[/<title[^>]*>(.*?)<\/title>/im, 1]
    if title.nil? || title.strip.empty?
        errors << "#{rel}: empty or missing <title>"
    end
    unless html =~ /<meta[^>]+charset/i
        errors << "#{rel}: missing <meta charset>"
    end

    # --- liquid leakage ---
    if html =~ /\{\{\s*[\w\.\|]+/ || html =~ /\{%\s*\w+/
        msg = "#{rel}: unresolved Liquid markup leaked into output"
        STRICT ? errors << msg : warnings << msg
    end

    # --- TODO / FIXME ---
    if html =~ /\b(TODO|FIXME)\b/
        msg = "#{rel}: contains TODO/FIXME marker"
        STRICT ? errors << msg : warnings << msg
    end

    # --- local link/asset resolution ---
    extract_refs(html).each do |tag, attr, value|
        candidates = resolve_local(value, path, ROOT)
        next if candidates.nil?
        unless candidate_exists?(candidates, existing)
            errors << "#{rel}: <#{tag} #{attr}=\"#{value}\"> -> not found in _site/"
        end
    end
end

# --- report ---
unless warnings.empty?
    puts "\nWarnings (#{warnings.size}):"
    warnings.first(50).each { |w| puts "  - #{w}" }
    puts "  ... (#{warnings.size - 50} more)" if warnings.size > 50
end

unless errors.empty?
    puts "\nErrors (#{errors.size}):"
    errors.first(50).each { |e| puts "  - #{e}" }
    puts "  ... (#{errors.size - 50} more)" if errors.size > 50
    exit 1
end

puts "\ncheck_html: OK — scanned #{existing.size} files, no errors."
exit 0
