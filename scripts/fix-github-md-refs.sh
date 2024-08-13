#!/bin/bash
# We'll post process the markdown files copied to the _build/rst folder to look
# for hard references to the github.com markdown file, for example
# (https://github.com/opea-project/.../blob/.../README.md) and make them
# relative to the _build/rst directory structure where docs are being built

# Work on the current directory or the directory passed as the first argument
# (as done in the makefile)

cd ${1:-.}

files=`grep -ril --include="*.md" 'github.com/opea-project.*\/[^\)]*\.md'`

# fix references to opea-project/blob/main/.../*.md to be to the repo name and
# subsequent path to the md file

sed -i 's/https:\/\/github.com\/opea-project\/\([^\/]*\)\/\(blob\|tree\)\/main\/\([^)]*\.md\)/\/\1\/\3/g' $files

# links such as (docs/...) should change to (/...) since docs repo is the build root

sed -i 's/(\/docs\//(\//g' $files

# fix tagging on mermaid diagrams, sigh.

sed -i 's/^```mermaid/```{mermaid}/' `grep -ril --include="*.md" '\`\`\`mermaid'`
