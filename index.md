---
layout: page
title: Alex Pretzlav
is_homepage: true
---

I've been writing iOS apps since 2009. You can find me by name on plenty of other sites. You can email me at alex at this domain.

I wrote a blog post in 2024! I'm pretty proud of that.

<div>
<h2>Posts</h2>

{% for post in site.posts  %}
  {% capture this_year %}{{ post.date | date: "%Y" }}{% endcapture %}
  {% capture this_month %}{{ post.date | date: "%B" }}{% endcapture %}
  {% capture next_year %}{{ post.previous.date | date: "%Y" }}{% endcapture %}
  {% capture next_month %}{{ post.previous.date | date: "%B" }}{% endcapture %}

  {% if forloop.first %}
    <ul>
  {% endif %}
      <li><a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a> <span>{{ post.date | date: "%B %e, %Y" }}</span></li>
  {% if forloop.last %}
    </ul>
  {% else %}
    {% if this_year != next_year %}
      </ul>
      <hr>
      <ul>
    {% endif %}
  {% endif %}
{% endfor %}
</div>