build: _posts/*
	bundle exec jekyll build

perms:
	chmod -R a+rX _site

deploy: build perms
	rsync -aP _site/ turnlav@alex.turnlav.net:alex.turnlav.net/blog/

serve:
	bundle exec jekyll serve --drafts --baseurl ''

server: serve