---
layout: page
permalink: /talks/
title: talks
description: Recorded conference presentations and invited seminars.
nav: true
nav_order: 6
---
<!-- _pages/talks.md — entries live in _data/talks.yml -->

<div class="talks">

  {% assign talk_list = site.data.talks | sort: "date" | reverse %}

  <ul class="talk-list">
    {% for talk in talk_list %}
    {% assign watch = "https://www.youtube.com/watch?v=" | append: talk.youtube %}
    <li class="talk-item">
      <a class="talk-thumb" href="{{ watch }}" target="_blank" rel="noopener noreferrer" aria-label="Watch {{ talk.title }} on YouTube">
        <img src="https://i.ytimg.com/vi/{{ talk.youtube }}/hqdefault.jpg" alt="Video thumbnail for {{ talk.title }}" loading="lazy">
        <span class="talk-play" aria-hidden="true"></span>
      </a>
      <div class="talk-body">
        <div class="talk-line">
          <span class="talk-kind">{{ talk.kind }}</span>
          <h3 class="talk-title"><a href="{{ watch }}" target="_blank" rel="noopener noreferrer">{{ talk.title }}</a></h3>
        </div>
        <p class="talk-meta">
          {{ talk.event }}{% if talk.location %} &middot; {{ talk.location }}{% endif %} &middot; {{ talk.date | date: "%B %-d, %Y" }}{% if talk.length %} &middot; {{ talk.length }}{% endif %}
        </p>
        {% if talk.description %}<p class="talk-desc">{{ talk.description }}</p>{% endif %}
        <p class="talk-links">
          <a href="{{ watch }}" target="_blank" rel="noopener noreferrer"><i class="fab fa-youtube"></i> watch</a>
          {% if talk.slides %}<a href="{{ talk.slides }}" target="_blank" rel="noopener noreferrer"><i class="fas fa-file-pdf"></i> slides</a>{% endif %}
          {% if talk.paper %}<a href="{{ talk.paper }}" target="_blank" rel="noopener noreferrer"><i class="fas fa-file-lines"></i> paper</a>{% endif %}
          {% if talk.event_url %}<a href="{{ talk.event_url }}" target="_blank" rel="noopener noreferrer"><i class="fas fa-link"></i> event</a>{% endif %}
        </p>
      </div>
    </li>
    {% endfor %}
  </ul>

</div>
