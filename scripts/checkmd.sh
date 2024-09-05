#!/bin/bash
# Copyright (C) 2024 Intel Corporation.
# SPDX-License-Identifier: Apache-2.0

# Use pymarkdown to recursively scan all markdown files for problems
# Disable rules we don't care to check.  If you find others that you'd like to
# ignore, simply add them to this list

drules=line-length,no-bare-urls,no-multiple-blanks,blanks-around-fences,no-hard-tabs,blanks-around-headings
drules=$drules,fenced-code-language,no-duplicate-heading,no-emphasis-as-heading,no-trailing-spaces

pymarkdown --disable-rules $drules scan -r .

