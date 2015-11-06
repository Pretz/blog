---
layout: page
header : Alex Pretzlav
is_more: true
---

I grew up in Venice, CA, went to [high school](http://xrds.org/) in Santa Monica, got a BA in Computer Science at Berkeley, lived in SF, worked for Yelp, moved to Austin, after a year or so joined up with [Silvercar](https://www.silvercar.com/). Now I'm about to embark on something new.

I have a <a href="http://apretz.tumblr.com" rel="me">tumblr</a> where I periodically post inscrutable quotes.


<div>
<hr>
<h1>Post Archive <small>(not much yet)</small></h1>

{% for post in site.posts  %}
  {% capture this_year %}{{ post.date | date: "%Y" }}{% endcapture %}
  {% capture this_month %}{{ post.date | date: "%B" }}{% endcapture %}
  {% capture next_year %}{{ post.previous.date | date: "%Y" }}{% endcapture %}
  {% capture next_month %}{{ post.previous.date | date: "%B" }}{% endcapture %}

  {% if forloop.first %}
    <h2>{{this_year}}</h2>
    <h3>{{this_month}}</h3>
    <ul>
  {% endif %}
  <li><span>{{ post.date | date: "%B %e, %Y" }}</span> &raquo; <a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></li>
  {% if forloop.last %}
    </ul>
  {% else %}
    {% if this_year != next_year %}
      </ul>
      <h2>{{next_year}}</h2>
      <h3>{{next_month}}</h3>
      <ul>
    {% else %}    
      {% if this_month != next_month %}
        </ul>
        <h3>{{next_month}}</h3>
        <ul>
      {% endif %}
    {% endif %}
  {% endif %}
{% endfor %}
</div>