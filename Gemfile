source 'https://rubygems.org'
require 'json'
require 'open-uri'
versions = JSON.parse(open('https://pages.github.com/versions.json').read)
gem 'github-pages', versions['github-pages']
gem 'octopress-autoprefixer'
gem 'rouge', '1.6.2'