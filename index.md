---
layout: page
header : Alex Pretzlav
is_homepage: true
---

I work as an iOS engineer at Twitter, Inc. You can find my Tweets at the link above, and can find me by name on plenty of other sites. You can email me at alex at this domain.

Maybe one day I'll write a new blog post. Not today.

<div>
<h1>Blog Posts</h1>

{% for post in site.posts  %}
  {% capture this_year %}{{ post.date | date: "%Y" }}{% endcapture %}
  {% capture this_month %}{{ post.date | date: "%B" }}{% endcapture %}
  {% capture next_year %}{{ post.previous.date | date: "%Y" }}{% endcapture %}
  {% capture next_month %}{{ post.previous.date | date: "%B" }}{% endcapture %}

  {% if forloop.first %}
    <h3 class="page-header">{{this_year}}</h3>
    <ul>
  {% endif %}

  <li><span>{{ post.date | date: "%B %e, %Y" }}</span> &raquo; <a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></li>

  {% if forloop.last %}
    </ul>
  {% else %}
    {% if this_year != next_year %}
      </ul>
      <h3 class="page-header">{{next_year}}</h3>
      <ul>
    {% else %}    
      {% if this_month != next_month %}
        </ul>
        <ul>
      {% endif %}
    {% endif %}
  {% endif %}
{% endfor %}
</div>