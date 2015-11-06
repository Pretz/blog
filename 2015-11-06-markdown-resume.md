---
layout: post
title: My Markdown Resume
tags: [self, programming]
description: How I made my resume in Markdown
---

Since graduating college, I've maintained my resume in [Markdown][md]. I wanted an HTML version of my resume to put online, but I also wanted a readable text version. Markdown is perfect for readable text that generates simple HTML. Then, it's easy to generate a good looking PDF from HTML.

There are plenty of other Markdown resume tools out there, but I've been using this since 2009 so I'm sticking with it. I've decided to finally extract it into a standalone tool and put it online. [Here it is on github][github], with a basic README. [Here's an example resume][sample].

[github]: https://github.com/Pretz/markdown-resume
[sample]: http://pretz.github.io/markdown-resume/

Some features:

* It uses [MultiMarkdown][mmd], which supports many useful Markdown extensions
* There's a `Makefile` for generating HTML and PDF output and scp'ing to a host
* There's a little bit of CSS magic for making the PDF look nicer
    - In particular, it will append ": $URL" to any links not configured with a "link" class, so link URLs appear in print
* It generates PDF via [wkhtmltopdf](http://wkhtmltopdf.org). You'll need to install it before PDF generation will work.
* It's easy to use as a submodule of an external git repository, so you can keep your resume private (I do).
* That's about it

[md]: https://daringfireball.net/projects/markdown/
[mmd]: http://fletcherpenney.net/multimarkdown/