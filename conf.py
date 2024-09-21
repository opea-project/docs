# OPEA Project documentation build configuration file
#
#
import os
import sys
from datetime import datetime

sys.path.insert(0, os.path.abspath('.'))

# Get OPEA version from GenAIComps/comps/version.py
sys.path.insert(0, os.path.abspath("../../../GenAIComps/comps"))
from version import __version__

RELEASE = ""
if "RELEASE" in os.environ:
   RELEASE = os.environ["RELEASE"]

# we've got some project sphinx extensions (link_roles)
sys.path.insert(0, os.path.join(os.path.abspath('.'), 'sphinx/extensions'))
extensions = [
   'sphinx.ext.graphviz',
   'sphinxcontrib.jquery',
   'sphinx_tabs.tabs',
   'myst_parser',
   'sphinxcontrib.mermaid',
   'link_roles',
   'sphinx_design',
   #'sphinx_md',
]

myst_enable_extensions = ["colon_fence"]
myst_fence_as_directive = ["mermaid"]

# sphinx_md config
sphinx_md_useGitHubURL = True

graphviz_output_format='png'
graphviz_dot_args=[
   '-Nfontname="verdana"',
   '-Gfontname="verdana"',
   '-Efontname="verdana"']

# Add any paths that contain templates here, relative to this directory.
templates_path = ['sphinx/_templates']

# The suffix(es) of source filenames.
# You can specify multiple suffix as a list of string:
#
source_suffix = ['.rst', '.md',
                 ]

# The master toctree document.
master_doc = 'index'

# General information about the project.
project = u'OPEA™'
this_year=str(datetime.now().year);
copyright = u'2024' + ('' if this_year == '2024' else ('-' + this_year)) + ' ' + project + ', a Series of LF Projects, LLC'
author = u'OPEA Project developers'

version = release = __version__
if not version:
  sys.stderr.write('Warning: Could not extract OPEA version from version.py\n')
  version = release = "unknown"


# files and directories to ignore when looking for source files.
exclude_patterns = [
        'scripts/*',
        ]
try:
    import sphinx_rtd_theme
except ImportError:
    sys.stderr.write('Warning: sphinx_rtd_theme missing. Use pip to install it.\n')
else:
    html_theme = "sphinx_rtd_theme"
    html_theme_path = [sphinx_rtd_theme.get_html_theme_path()]
    html_theme_options = {
        'canonical_url': '',
        'analytics_id': 'G-3QH5804YP8',
        'logo_only': False,
        'display_version': True,
        #'prev_next_buttons_location': 'None',
        # Toc options
        'collapse_navigation': False,
        'sticky_navigation': True,
        'navigation_depth': 3,
    }


# Here's where we (manually) list the document versions maintained on
# the published doc website.  On a regular basis we publish to the
# /latest folder but when releases are made, we publish to a /<relnum>
# folder (specified via the version)

if tags.has('release'):
   is_release = True
   docs_title = '%s' %(version)
   current_version = version
   if RELEASE:
      version = release = current_version = RELEASE
      docs_title = '%s' %(version)
else:
   version = current_version = "latest"
   is_release = False
   docs_title = 'Latest'

html_context = {
   'current_version': current_version,
   'docs_title': docs_title,
   'is_release': is_release,
   'versions': ( ("latest", "/latest/"),
                 ("1.0", "/1.0/"),
               )
    }


# Theme options are theme-specific and customize the look and feel of a theme
# further.  For a list of options available for each theme, see the
# documentation.
#
# html_theme_options = {}

html_logo = 'images/opea-horizontal-white-w200.png'
html_favicon = 'images/OPEA-favicon-32x32.png'

numfig = True
numfig_format = {'figure': 'Figure %s', 'table': 'Table %s', 'code-block': 'Code Block %s'}

# paths that contain custom static files (such as style sheets)
html_static_path = ['sphinx/_static']

def setup(app):

   app.add_css_file("opea-custom.css")
   app.add_js_file("opea-custom.js")

# Disable "Created using Sphinx" in the HTML footer. Default is True.
html_show_sphinx = False

# If true, links to the reST sources are added to the pages.
html_show_sourcelink = True

# If not '', a 'Last updated on:' timestamp is inserted at every page
# bottom,
# using the given strftime format.
html_last_updated_fmt = '%b %d, %Y'


rst_epilog = """
.. include:: /sphinx/substitutions.txt
"""
