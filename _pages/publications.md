---
layout: page
permalink: /publications/
title: publications
nav: true
nav_order: 1
---
<!-- _pages/publications.md -->
<div class="publications">
  {% assign all_entries = site | dig: 'scholar', 'bibliography', 'papers' %}
  {% unless all_entries %}
    {% assign all_entries = site | dig: 'scholar', 'bibliography' %}
  {% endunless %}
  {% unless all_entries %}
    {% assign all_entries = '' | split: '' %}
  {% endunless %}

  {% if all_entries != empty %}
    {% assign published_entries = all_entries | where_exp: 'item', 'item.journal' | where_exp: 'item', "item.journal != ''" %}
    {% assign published_entries = published_entries | where_exp: 'item', "item.journal contains 'arXiv preprint' == false" %}
    {% assign published_entries = published_entries | where_exp: 'item', "item.journal contains 'Available at SSRN' == false" %}

    {% assign working_entries = all_entries | where_exp: 'item', "item.journal == nil or item.journal == '' or item.journal contains 'arXiv preprint' or item.journal contains 'Available at SSRN'" %}

    {% assign published_by_year = published_entries | group_by: 'year' | sort: 'name' | reverse %}
    {% for group in published_by_year %}
      {% assign year = group.name %}
      {% if year %}
        <h2 class="year">{{ year }}</h2>
      {% else %}
        <h2 class="year">Undated</h2>
      {% endif %}
      {% assign sorted_entries = group.items | sort: 'month' | reverse %}
      {% for entry in sorted_entries %}
        {% include publication_entry.html entry=entry %}
      {% endfor %}
    {% endfor %}

    {% if working_entries.size > 0 %}
      <h2 class="year">Working Papers</h2>
      {% assign sorted_working = working_entries | sort: 'year' | reverse %}
      {% for entry in sorted_working %}
        {% include publication_entry.html entry=entry %}
      {% endfor %}
    {% endif %}
  {% endif %}
</div>
