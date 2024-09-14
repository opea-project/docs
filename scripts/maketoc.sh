#!/bin/bash
# Copyright (C) 2024 Intel Corporation.
# SPDX-License-Identifier: Apache-2.0

# For all directories, create a H2 title with the directory name and a
# .toctree directive with the repo name and
# those directory names, something like this:
#
# AudioQnA Application
# ********************
#
# .. toctree::
#    :maxdepth: 1
#    :glob:
#
#    /GenAIExamples/AudioQnA/*
#    /GenAIExamples/AudioQnA/**/*
#
# ls -d1 */   returns something like this:
#
# AgentQnA/
# AudioQnA/
# ChatQnA/
# CodeGen/
# CodeTrans/
# DocIndexRetriever/
#
#
#  Create a title based on the directory name and print it.
#  Use a gsub to turn every character in the title into an * for the
#  heading underline and print it.

cd ../GenAIExamples

ls -d1 */ | \
   awk \
     -v repo="GenAIExamples" \
     -e '{dirname=substr($0,1,length($0)-1); title=dirname " Application"; \
         print title;gsub(/./,"*",title); print title; \
         print "\n.. rst-class:: rst-columns\n\n.. toctree::\n   :maxdepth: 1\n   :glob:\n\n   /" \
         repo "/" dirname "/*\n   /" \
         repo "/" dirname "/**/*\n";}' > ../docs/_build/rst/examples/examples.txt

#
#  The components directory names in GenAIComps/comps are all lowercase, so uppercase
#  just the first character for the title.
#

cd ../GenAIComps/comps

ls -d1 [a-zA-Z]*/ | \
   awk \
     -v repo="GenAIComps" \
     -e '{dirname=substr($0,1,length($0)-1); title=toupper(substr(dirname,1,1)) substr(dirname,2) " Microservice"; \
         print title;gsub(/./,"*",title); print title; \
         print "\n.. rst-class:: rst-columns\n\n.. toctree::\n   :maxdepth: 1\n   :glob:\n\n   /" \
         repo "/comps/" dirname "/*\n   /" \
         repo "/comps/" dirname "/**/*\n";}' > ../../docs/_build/rst/microservices/microservices.txt


