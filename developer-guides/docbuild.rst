.. _opea_doc_generation:

OPEA Documentation Generation
#############################

These instructions walk you through generating the OPEA project
documentation and publishing it to https://opea-project.github.io.
You can also use these instructions to generate the OPEA documentation
on your local system.

.. contents::
   :local:
   :depth: 1

Documentation Overview
**********************

OPEA project content is written using combination of markdown (``.md``) and reStructuredText (``.rst``) markup
languages (with Sphinx extensions), and processed
using Sphinx to create a formatted stand-alone website. Developers can
view this content either in its raw form as .rst markup files, or you
can generate the HTML content and view it with a web browser directly on
your workstation.

You can read details about `markdown`_, `reStructuredText`_, and `Sphinx`_ from
their respective websites.

The project's documentation contains the following items:

* ReStructuredText and markdown source files used to generate documentation found at the
  https://opea-project.github.io website. All of the documentation sources
  are found in the ``github.com/opea-project`` repos, rooted in the ``docs`` repo.
  There's also documentation in the repos where the project's code is
  maintained, such as ``GenAIComps``, ``GenAIExamples``, and others.

.. graphviz:: images/doc-gen-flow.dot
   :align: center
   :caption: Documentation Generation Flow


Set Up the Documentation Working Folders
****************************************

You'll need ``git`` installed to get the working folders set up:

* For an Ubuntu development system use:

  .. code-block:: bash

     sudo apt install git

Here's the recommended folder setup for documentation contributions and
generation, a parent folder called ``opea-project`` holds six locally cloned
repos from the opea-project:

.. code-block:: none

   opea-project
   ├── docs
   ├── GenAIComps
   ├── GenAIEval
   ├── GenAIExamples
   ├── GenAIInfra
   ├── Governance

The parent ``opea-project`` folder is there to organize the cloned repos from
the project.  If you have repo publishing
rights, we'll also be creating a publishing area later in these steps.

In the following steps, you'll create a fork of all the upstream OPEA project
repos needed to build the documentation to your personal GitHub account, clone
your personal fork to your local development computer, and then link that to the
upstream repo as well.  You'll only need to do this once to set up the folder
structure:

#. Use your browser to visit https://github.com/opea-project and do a
   fork of the **docs** repo to your personal GitHub account.)

   .. image:: images/opea-docs-fork.png
      :align: center
      :class: drop-shadow

#. At a command prompt, create a working folder on your development computer and
   clone your personal ``docs`` repository:

   .. code-block:: bash

      cd ~
      mkdir opea-project && cd opea-project
      git clone https://github.com/<github-username>/docs.git

#. For the cloned local repo, tell git about the upstream repo:

   .. code-block:: bash

      cd docs
      git remote add upstream https://github.com/opea-project/docs.git

   After that, you'll have ``origin`` pointing to your cloned personal repo and
   ``upstream`` pointing to the project repo.

#. Do the same steps (fork to your personal account, clone to your local
   computer, and setup the git upstream remote) for the other repos containing
   project documentation:

   * GenAIComps
   * GenAIEval
   * GenAIExamples
   * GenAIInfra
   * Governance

#. If you haven't done so already, be sure to configure git with your name
   and email address for the ``signed-off-by`` line in your commit messages:

   .. code-block:: bash

      git config --global user.name "David Developer"
      git config --global user.email "david.developer@company.com"

Install the Documentation Tools
*******************************

Our documentation processing has been tested to run with Python 3.8.10 and
later, and these other tools:

* sphinx                    version: 7.3.0
* docutils                  version: 0.20
* sphinx-rtd-theme          version: 2.0.0
* sphinx-tabs               version: 3.4.5
* myst-parser               version: 3.0.1
* sphinxcontrib-mermaid     version: 0.9.2

Depending on your Linux version, install the needed tools.


For Ubuntu use:

.. code-block:: bash

   sudo apt install python3-pip python3-wheel make graphviz

Then use ``pip3`` to install the remaining Python-based tools specified in the
`scripts/requirements.txt` file

.. code-block:: bash

   cd ~/opea-project/docs
   pip3 install --user -r scripts/requirements.txt

Use this command to add ``$HOME/.local/bin`` to the front of your ``PATH`` so
the system will find expected versions of these Python utilities such as
``sphinx-build`` (you should first check whether this folder is already on your
path):

.. code-block:: bash

   printf "\nexport PATH=\$HOME/.local/bin:\$PATH" >> ~/.bashrc

.. important::

   You will need to open a new terminal for this change to take effect.
   Adding this to your ``~/.bashrc`` file ensures it is set by default.

And with that you're ready to generate the documentation.

.. note::

   We've provided a script you can run to show what versions of the
   documentation building tools are installed and compare with the
   tool versions shown above. This tool will also verify you're using tool
   versions known to work together::

      doc/scripts/show-versions.py

   for example:

   .. code-block:: console

      ~/opea-project/docs$ scripts/show-versions.py

      doc build tool versions found on your system per /home/david/opea-project/docs/scripts/requirements.txt...

      sphinx                    version: 7.3.0
      docutils                  version: 0.20
      sphinx-rtd-theme          version: 2.0.0
      sphinx-tabs               version: 3.4.5
      myst-parser               version: 3.0.1
      sphinx-md                 version: 0.0.3
      sphinxcontrib-mermaid     version: 0.9.2


Documentation Presentation Theme
********************************

Sphinx supports easy customization of the generated HTML documentation
appearance through the use of themes.  The ``sphinx-rtd-theme`` (Read The Docs)
theme is installed as part of the ``requirements.txt`` list above.  Tweaks to
the standard ``read-the-docs`` appearance are added by using CSS and JavaScript
customization found in ``doc/_static``, and theme template overrides found in
``doc/_templates``. If you change to another theme, you'll need to tweak
these customizations, not something for the faint of heart.

The Sphinx build system creates document cache information that attempts to
expedite documentation rebuilds, but occasionally can cause an unexpected error
or warning to be generated.  Doing a ``make clean`` to create a clean generation
environment and a ``make html`` again generally fixes these issues.


Run the Documentation Processors
********************************

The ``docs`` folder (and cloned sibling repos) have all the doc source files,
images, extra tools, and ``Makefile`` for generating a local copy of the OPEA
technical documentation. (The ``Makefile`` copies all needed files from these
cloned repos into a temporary ``_build`` working folder.)

.. code-block:: bash

   cd ~/opea-project/docs
   make html

Depending on your development system, it will take less a minute to collect and
generate the HTML content.  When done, you can view the HTML output in
``~/opea-project/docs/_build/html/index.html``. You can also ``cd`` to the
``_build/html`` folder and run a local web server with the command:

.. code-block:: bash

   cd _build/html
   python3 -m http.server

and use your web browser to open the URL:  ``http://localhost:8000``.

Publish Content
***************

If you have merge rights to the opea-project repo called
``opea-project.github.io``, you can update the public project documentation
found at https://opea-project.github.io.

You'll need to do a one-time clone of the upstream repo (we publish
directly to the upstream repo rather than to a personal forked copy):

.. code-block:: bash

   cd ~/opea-project
   git clone https://github.com/opea-project/opea-project.github.io.git

Then, after you've verified the generated HTML from ``make html`` looks
good, you can push directly to the publishing site with:

.. code-block:: bash

   make publish

This uses git commands to synchronize the new content with what's
already published and will delete files in the publishing repo's
**latest** folder that are no longer needed. New or changed files from
the newly-generated HTML content are added to the GitHub pages
publishing repo.  The public site at https://opea-project.github.io will
be updated by the `GitHub pages system
<https://guides.github.com/features/pages/>`_, typically within a few
minutes.

Document Versioning
*******************

The https://opea-project.github.io site has a document version selector
at the top of the left nav panel.  The contents of this version
selector are defined in the ``conf.py`` sphinx configuration file,
specifically:

.. code-block:: python
   :emphasize-lines: 5-6

   html_context = {
      'current_version': current_version,
      'docs_title': docs_title,
      'is_release': is_release,
      'versions': ( ("latest", "/latest/"),
                    ("0.8", "/0.8/"),
                    ("0.7", "/0.7/"),
                  )
       }


As new versions of OPEA documentation are added, update this
``versions`` selection list to include the version number and publishing
folder.  Note that there's no direct selection to go to a newer version
from an older one, without going to ``latest`` first.

By default, documentation build and publishing both assume we're generating
documentation for the main branch and publishing to the ``/latest/``
area on https://opea-project.github.io. When we're generating the
documentation for a tagged version (e.g., 0.8), check out that version
of all the component repos, and add some extra flags to the ``make`` commands:

.. code-block:: bash

   cd ~/opan-project/docs
   git checkout v0.8
   make clean
   make DOC_TAG=release RELEASE=0.8 html
   make DOC_TAG=release RELEASE=0.8 publish

.. _filter_expected:

Filter Expected Warnings
************************

Alas, there are some known issues with the Sphinx processing that generate
warnings.  We've added a post-processing filter on the output of the
documentation build process to check for "expected" messages from the generation
process output. By doing this, only "unexpected" messages will be reported and
cause the build process to fail with a message:

.. code-block:: console

   New errors/warnings found, please fix them:

followed by messages that weren't expected. If all messages were filtered away,
the build process will report as successful, reporting:

.. code-block:: console

   No new errors/warnings.

The output from the Sphinx build is processed by the Python script
``scripts/filter-known-issues.py`` together with a set of filter
configuration files in the ``.known-issues`` folder.  (This
filtering is done as part of the ``Makefile``.)

You can modify the filtering by adding or editing a conf file in the
``.known-issues`` folder, following the examples found there.

.. _reStructuredText: https://sphinx-doc.org/rest.html
.. _markdown: https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax
.. _Sphinx: https://sphinx-doc.org/
