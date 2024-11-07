# makefile for Sphinx documentation
#

ifeq ($(VERBOSE),1)
  Q =
else
  Q = @
endif

# You can set these variables from the command line.
SPHINXOPTS    ?= -q
SPHINXBUILD   = sphinx-build
SPHINXPROJ    = "OPEA Project"
BUILDDIR      ?= _build
SOURCEDIR     = $(BUILDDIR)/rst
LATEXMKOPTS   = "-silent -f"

# Document publication assumes the folder structure is setup with the
# opea-project repos: GenAIExamples (etc), docs, and opea.github.io repos as
# sibling folders. make is run inside the opea-project/docs folder. Content from
# other sibling repos is copied to a build folder to get all content in one
# tree.


OPEA_BASE     = $(CURDIR)/..
DOC_TAG      ?= development
RELEASE      ?= latest
PUBLISHDIR    = $(OPEA_BASE)/opea-project.github.io/$(RELEASE)
# scripts/rsync-include.txt lists file extensions to look for and copy
RSYNC_OPTS    = -am --exclude='.github/pull_request_template.md' --include='*/' --include-from=scripts/rsync-include.txt --exclude='*'
RSYNC_DIRS    = GenAIComps  GenAIEval  GenAIExamples  GenAIInfra

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(OPTS)
	@echo ""
	@echo "make publish"
	@echo "   publish generated html to opea.github.io site:"
	@echo "   specify RELEASE=name to publish as a tagged release version"
	@echo "   and placed in a version subfolder.  Requires repo merge permission."

.PHONY: help Makefile content html singlehtml clean publish

# Copy all the rst and md content (and images, etc) into the _build/rst folder
# including rst and md content

# GenAIComps  GenAIEval  GenAIExamples  GenAIInfra
content:
	$(Q)mkdir -p $(SOURCEDIR)
	$(Q)rsync -a --exclude=$(BUILDDIR) . $(SOURCEDIR)
	$(Q)for dir in $(RSYNC_DIRS); do\
		rsync $(RSYNC_OPTS) ../$$dir $(SOURCEDIR); \
		done
# temporarily, copy docs content too (were in the docs-work)
#	$(Q)rsync $(RSYNC_OPTS) ../docs/* $(SOURCEDIR)
	$(Q)find $(SOURCEDIR) -type f -empty -name "README.md" -delete
	$(Q)scripts/fix-github-md-refs.sh $(SOURCEDIR)
	$(Q)scripts/maketoc.sh $(SOURCEDIR)


html: content
	@echo making HTML content
	$(Q)./scripts/show-versions.py
	@echo zjy make html
	$(Q)$(SPHINXBUILD) -t $(DOC_TAG) -b html -d $(BUILDDIR)/doctrees $(SOURCEDIR) $(BUILDDIR)/html $(SPHINXOPTS) $(OPTS) > $(BUILDDIR)/doc.log 2>&1
	$(Q)./scripts/filter-doc-log.sh $(BUILDDIR)/doc.log
	@echo zjy done
singlehtml: content 
	-$(Q)$(SPHINXBUILD) -t $(DOC_TAG) -b singlehtml -d $(BUILDDIR)/doctrees $(SOURCEDIR) $(BUILDDIR)/html $(SPHINXOPTS) $(OPTS) > $(BUILDDIR)/doc.log 2>&1
	$(Q)./scripts/filter-doc-log.sh $(BUILDDIR)/doc.log


# Remove generated content

clean:
	rm -fr $(BUILDDIR)

# Copy material over to the GitHub pages staging repo
# along with a README, index.html redirect to latest/index.html, robots.txt (for
# search exclusions), and tweak the Sphinx-generated 404.html to work as the
# site-wide 404 response page.  (We generate the 404.html with Sphinx so it has
# the current left navigation contents and overall style.)

publish:
	mkdir -p $(PUBLISHDIR)
	cd $(PUBLISHDIR)/..; git pull origin main
	rm -fr $(PUBLISHDIR)/*
	cp -r $(BUILDDIR)/html/* $(PUBLISHDIR)
ifeq ($(RELEASE),latest)
	cp scripts/publish-README.md $(PUBLISHDIR)/../README.md
	scripts/publish-redirect.sh $(PUBLISHDIR)/../index.html latest/index.html
	sed 's/<head>/<head>\n  <base href="https:\/\/opea-project.github.io\/latest\/">/' $(BUILDDIR)/html/404.html > $(PUBLISHDIR)/../404.html
endif
	cd $(PUBLISHDIR)/..; git add -A; git commit -s -m "publish $(RELEASE)"; git push origin main;

server:
	cd _build/html; python3 -m http.server


# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(OPTS) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(OPTS)
