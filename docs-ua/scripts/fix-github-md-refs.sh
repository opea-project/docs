#!/bin/bash
# Copyright (C) 2024 Intel Corporation.
# SPDX-License-Identifier: Apache-2.0

# We'll post process the markdown files copied to the _build/rst folder to look
# for hard references to the github.com markdown file, for example
# (https://github.com/opea-project/.../blob/.../README.md) and make them
# relative to the _build/rst directory structure where docs are being built

# Work on the current directory or the directory passed as the first argument
# (as done in the makefile).  Normally is _build/rst

cd ${1:-.}

# look for markdown files containing a hard github.com/opea-project/...
# reference to a markdown file

mdfiles=`grep -ril --include="*.md" 'github.com/opea-project.*\/[^\)]*'`

# fix references to opea-project/tree/main/.../*.md or blob/.../*.md to be to the repo name and
# subsequent path to the md file  \1 is repo \3 is file path \4 is an optional #xxx target

#sed -i 's/(https:\/\/github.com\/opea-project\/\([^\/]*\)\/\(blob\|tree\)\/main\/\([^)]*\.md\)/(\/\1\/\3/g' $mdfiles
#sed -i  's/(https:\/\/github.com\/opea-project\/\([^\/]*\)\/\(blob\|tree\)\/main\/\([^#)]*\)\(#[^)]*\)*)/(\/\1\/\3\/README.md\4)/g' $mdfiles
sed -i  's/(https:\/\/github.com\/opea-project\/\([^\/]*\)\/\(blob\|tree\)\/main\/\([^#)]*\.md\)\(#[^)]*\)*)/(\/\1\/\3\4)/g' $mdfiles

# After that, inks to the docs repo such as [blah](docs/...) should have the repo name removed since docs repo is the build root

sed -i 's/](\/docs\//](\//g' $mdfiles

# links to a folder should instead be to the folder's README.md
# Not automating this for now since there are valid folder references
# sed -i 's/\(\/[a-zA-z]*\))/\1\/README.md)/g' $files

# fix tagging on code blocks, for myst parser (vs. GFM syntax)
# with myst_fence_as_directive = ["mermaid"] we don't need to do this any mre
# sed -i 's/^```mermaid/```{mermaid}/' `grep -ril --include="*.md" '\`\`\`mermaid'`

# fix references to opea-project/blob/main/... to use the special role # :{repo}_raw:`{path to file}`
# alas, using sphinx roles doesn't work in markdown files, so leave them alone
# mdfiles=`grep -ril --include="*.md" '(https:\/\/github.com\/opea-project\/[^\/]*\/blob\/main\/[^\)]*)'`
# sed -i # 's/(https:\/\/github.com\/opea-project\/\([^\/]*\)\/blob\/main\/\([^)]*\)/(:\1_blob:`\2`/g' $mdfiles

# find CODEOWNERS files and generate a rst table for each one found. This file
# will is included by the codeowners.md file during the doc build so we keep
# these lists up-to-date.

cfiles=`find -name CODEOWNERS | sort`
scripts/codeowners_to_md.py $cfiles > community/codeowners.txt
