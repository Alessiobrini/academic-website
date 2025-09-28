---
layout: page
permalink: /publications/
title: publications
nav: true
nav_order: 1
---
<!-- _pages/publications.md -->
<div class="publications">
  {% assign bibliography = site.scholar.bibliography %}
  {% assign all_entries = bibliography['papers'] | default: bibliography.entries %}
  {% if all_entries == nil %}
    {% assign _ = all_entries[0] %}
  {% endif %}
  {% assign working_papers = all_entries | where_exp: 'entry', "entry.journal and (entry.journal contains 'arXiv' or entry.journal contains 'SSRN')" %}
  {% assign working_keys = working_papers | map: 'key' %}
  {% assign grouped_by_year = all_entries | group_by: 'year' %}
  {% assign sorted_groups = grouped_by_year | sort: 'name' | reverse %}

  {% for group in sorted_groups %}
    {% assign has_published = false %}
    {% for entry in group.items %}
      {% unless working_keys contains entry.key %}
        {% assign has_published = true %}
        {% break %}
      {% endunless %}
    {% endfor %}
    {% if has_published %}
      {% assign year_label = group.name | default: 'Undated' %}
      <h2 class="year">{{ year_label }}</h2>
      {% for entry in group.items %}
        {% unless working_keys contains entry.key %}
          {% include bibliography_entry.html entry=entry %}
        {% endunless %}
      {% endfor %}
    {% endif %}
  {% endfor %}

  {% assign working_count = working_papers | size %}
  {% if working_count > 0 %}
    <h2>Working Papers</h2>
    {% assign sorted_working = working_papers | sort: 'year' | reverse %}
    {% for entry in sorted_working %}
      {% include bibliography_entry.html entry=entry %}
    {% endfor %}
  {% endif %}
</div>
