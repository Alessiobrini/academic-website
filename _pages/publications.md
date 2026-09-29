---
layout: page
permalink: /publications/
title: publications
description: Peer-reviewed articles and working papers on machine learning in finance, volatility forecasting, reinforcement learning for trading and hedging, and decentralized finance.
nav: true
nav_order: 1
---
<!-- _pages/publications.md -->
<div class="publications">

  <h2>Published Papers</h2>
  {% bibliography -f papers -q @*[keywords=published]* --group_by year --group_order descending %}

  <h2>Working Papers</h2>
  {% bibliography -f papers -q @*[keywords=working-paper]* --group_by year --group_order descending %}

</div>
