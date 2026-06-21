---
title: Papers & Presentations
layout: page
---

## Publications

<div class="publication">
    <h3 class="title">TaleTrain: AI Scaffolding for Parent–Child Video Story Retelling at Home</h3>
    <p class="authors">Sangwon Park, <strong>Sieun Park</strong>, HyunA Seo, Minkyu Shim, Youngki Lee</p>
    <p class="status">Under Review</p>
</div>

<div class="publication">
    <h3 class="title">ODFuse: Reducing Reasoning Overhead in Tool-Use Agents via Observation-Dependency-Guided Fusion</h3>
    <p class="authors">Hyunwoo Jung, <strong>Sieun Park</strong>, Minkyu Shim, Youngki Lee</p>
    <p class="status">Under Review</p>
</div>

## Presentations

<div class="presentation-list">
{% assign presentations = site.presentations | sort: "order" %}
{% for p in presentations %}
  <div class="presentation-entry">
    <a class="presentation-title" href="{{ p.url | relative_url }}">{{ p.title }}</a>
    {% if p.venue %}<span class="presentation-venue">{{ p.venue }}</span>{% endif %}
    {% if p.chips and p.chips != empty %}
    <span class="chip-row">
      {% for chip in p.chips %}
        <a class="chip" href="{{ p.url | relative_url }}#{{ chip.anchor }}">{{ chip.label }}</a>
      {% endfor %}
    </span>
    {% endif %}
  </div>
{% endfor %}
</div>

<style>
/* Publications */
.publication { margin-bottom: 2em; padding-bottom: 1em; border-bottom: 1px solid #eee; }
.publication:last-child { border-bottom: none; }
.publication .title { margin-bottom: 0.5em; font-size: 1.2em; }
.publication .authors { color: #666; font-style: italic; margin-bottom: 0.5em; }
.publication .status { color: #888; font-size: 0.9em; }

/* Presentations */
.presentation-entry { margin-bottom: 1.6em; padding-bottom: 1.2em; border-bottom: 1px solid #eee; }
.presentation-entry:last-child { border-bottom: none; }
.presentation-title { font-size: 1.15em; font-weight: 600; color: inherit; text-decoration: none; }
.presentation-title:hover { color: #9300ff; text-decoration: underline; }
.presentation-venue { display: block; color: #666; font-style: italic; font-size: 0.95em; margin-top: 0.3em; }

/* Chips: compact, round-sided pills ~90% of the text height. Title + chips are clickable. */
.chip-row { display: inline-flex; flex-wrap: wrap; gap: 0.45em; margin-top: 0.7em; vertical-align: middle; }
.chip {
    display: inline-flex; align-items: center;
    font-size: 0.78em; font-weight: 700; line-height: 1; letter-spacing: 0.04em;
    padding: 0.42em 0.75em;
    color: #4b0082; background: transparent;
    border: 1.5px solid #4b0082; border-radius: 999px;
    text-decoration: none; transition: all .15s ease-in-out;
}
.chip:hover { background: #4b0082; color: #fff; }

@media (prefers-color-scheme: dark) {
    .presentation-title:hover { color: #c79cff; }
    .chip { color: #c79cff; border-color: #c79cff; }
    .chip:hover { background: #c79cff; color: #1a1a1a; }
}
</style>
