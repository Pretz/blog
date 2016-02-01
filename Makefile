build: _posts/*
	bundle exec jekyll build

perms:
	chmod -R a+rX _site

newpost:
	$(eval LOL := $(shell date "+%Y-%m-%d")-newpost.md)
	$(eval HEADER := '---\nlayout: post\ntitle: "Title"\ntags: [meta]\ndescription: blah\n---')
	echo ${HEADER} >> "_posts/${LOL}"

deploy: build perms
	rsync -aP _site/ turnlav@alex.turnlav.net:alex.turnlav.net/blog/

serve:
	bundle exec jekyll serve --incremental --drafts --baseurl ''

server: serve