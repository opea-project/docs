# Copyright (c) 2019-2024 Intel Corporation.
#
# SPDX-License-Identifier: Apache-2.0

# based on http://protips.readthedocs.io/link-roles.html

from __future__ import print_function
from __future__ import unicode_literals
import re
import os
import os.path
from os import path
import subprocess
from docutils import nodes


def run_cmd_get_output(cmd):
    try:
        with open(os.devnull, 'w') as devnull:
            output = subprocess.check_output(cmd, stderr=devnull, shell=True).strip()
    except subprocess.CalledProcessError as e:
        output = e.output.decode('ascii')

    return output

def get_github_rev():
    tag = run_cmd_get_output('git describe --tags --exact-match')
    if tag:
        return tag.decode("utf-8")
    else:
        return 'main'


def setup(app):
    rev = get_github_rev()

    baseurl = 'https://github.com/opea-project/'
    repos = ["GenAIComps", "GenAIEval", "GenAIExamples", "GenAIInfra", "Governance", "docs"]

    for r in repos:
        app.add_role('{}_file'.format(r), autolink('{}{}/blob/{}/%s'.format(baseurl, r, rev)))
        app.add_role('{}_raw'.format(r), autolink('{}{}/raw/{}/%s'.format(baseurl, r, rev)))

    # The role just creates new nodes based on information in the
    # arguments; its behavior doesn't depend on any other documents.
    return {
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }


def autolink(pattern):
    def role(name, rawtext, text, lineno, inliner, options={}, content=[]):
        m = re.search(r'(.*)\s*<(.*)>', text)
        if m:
            link_text = m.group(1)
            link = m.group(2)
        else:
            link_text = text
            link = text
        url = pattern % (link,)
        node = nodes.reference(rawtext, link_text, refuri=url, **options)
        return [node], []
    return role
