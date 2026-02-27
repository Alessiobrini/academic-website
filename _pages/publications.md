---
layout: page
permalink: /publications/
title: publications
nav: true
nav_order: 1
---
<!-- _pages/publications.md -->
<div class="publications">

  <h2>Published Papers</h2>
  {% bibliography -f papers -q @*[keywords=published]* --sort_by year --order descending --group_by none %}

  <h2>Working Papers</h2>
  {% bibliography -f papers -q @*[keywords=working-paper]* --sort_by year --order descending --group_by none %}

</div>
