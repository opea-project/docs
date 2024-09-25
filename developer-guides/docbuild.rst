.. _opea_doc_generation:

OPEA Documentation Generation
#############################

These instructions walk you through generating the OPEA project documentation
and publishing it to https://opea-project.github.io.  You can also use these
instructions to generate the OPEA documentation on your local system.

.. contents::
   :local:
   :depth: 1

Documentation Overview
**********************

OPEA project content is written using combination of markdown (``.md``) and
reStructuredText (``.rst``) markup languages (with Sphinx extensions such as
`Myst <https://myst-parser.readthedocs.io/en/latest/index.html>`_), and
processed using Sphinx to create a formatted stand-alone website. 
The best reading experience is by viewing the generated HTML at
https://opea-project.github.io.
While working on new content or editing existing content, developers can
generate the HTML content locally and view it with a web browser.

You can read details about `markdown`_, `reStructuredText`_, and `Sphinx`_ from
their respective websites.

The project's documentation is a collection of ReStructuredText and markdown
source files used to generate documentation found at the
https://opea-project.github.io website. All of the documentation sources are
found in the ``github.com/opea-project`` project repos, organized and rooted in
the ``docs`` repo.  Much of the detailed documentation lives in the repos where
the project's code is maintained: ``GenAIComps``, ``GenAIEval``,
``GenAIExamples``, and ``GenAIInfra``. The documentation generation process
collects all the needed files from all these repos into one building area to
create the final generated HTML.

.. graphviz:: images/doc-gen-flow.dot
   :align: center
   :caption: Documentation Generation Flow

Some content is manipulated or generated during the doc build process:

- Because markdown doesn't directly support cross-repo document linking, we use
  full URLs to link to the markdown files in other project repos, for example a
  link to a document in the GenAIInfra repo from a document in the GenAIExamples
  repo would look like this:

  ```
  See [GMC Install](https://github.com/opea-project/GenAIInfra/tree/main/microservices-connector/README.md).
  ```

  That link works when reading the markdown file in the github.com repo, but
  should be changed to reference the generated HTML file in the github.io
  rendering.

- When new examples appear in the GenAIExamples repo, the indexing page that
  lists all the examples is updated automatically by generating it at doc build
  time by scanning the directory structure.  The list of microservices is also
  self-updated when new microservices are added to the GenAIComps/comps
  directory.

- References in markdown files to markdown files (.md file extension) are
  converted to the corresponding generated HTML files by Sphinx using the Myst and
  sphinx-md extensions.

Set Up the Documentation Working Folders
****************************************

To begin, you'll need ``git`` installed to get the working folders set up:

* For an Ubuntu development system use:

  .. code-block:: bash

     sudo apt install git

Here's the recommended folder setup for documentation contributions and
generation, a parent folder called ``opea-project`` holds five locally
cloned repos from the opea-project.  You can use a different name for the parent
folder but the doc build process assumes the repo names are as shown here:

.. code-block:: none

   opea-project
   ├── docs
   ├── GenAIComps
   ├── GenAIEval
   ├── GenAIExamples
   ├── GenAIInfra

The parent ``opea-project`` folder is there to organize the cloned repos
from the project.

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

#. At a command prompt, create the top working folder on your development
   computer and clone your personal ``docs`` repository there:

   .. code-block:: bash

      cd ~
      mkdir opea-project && cd opea-project
      git clone https://github.com/<github-username>/docs.git

#. For the cloned local repo, tell git about the upstream repo:

   .. code-block:: bash

      cd docs
      git remote add upstream https://github.com/opea-project/docs.git

   After that, you'll have ``origin`` pointing to your cloned personal ``docs``
   repo and ``upstream`` pointing to the project ``docs`` repo.

#. Return to the parent directory with ``cd ..``

#. Now do the same steps (fork to your personal account, clone to your local
   computer, and setup the git upstream remote) for the other four repos
   replacing the docs.git repo name in the previous step
   with the appropriate repo name in this list:

   * ``GenAIComps``
   * ``GenAIEval``
   * ``GenAIExamples``
   * ``GenAIInfra``


#. If you haven't done so already, configure git with your name
   and email address for the ``Signed-off-by`` line in your commit messages:

   .. code-block:: bash

      git config --global user.name "David Developer"
      git config --global user.email "david.developer@company.com"

Install the Documentation Tools
*******************************

Our documentation processing has been tested to run on Ubuntu (both natively and
in Windows Subsystem for Windows (wsl) with Python 3.8.10 and
later, and these other tools:

* sphinx                    version: 7.3.0
* docutils                  version: 0.20
* sphinx-rtd-theme          version: 2.0.0
* sphinx-tabs               version: 3.4.5
* myst-parser               version: 3.0.1
* sphinx-md                 version: 0.0.3
* sphinxcontrib-mermaid     version: 0.9.2
* pymarkdownlnt             version: 0.9.21

Depending on your Linux version, install the needed tools.

.. important::

   You should consider using the `Python virtual environment`_ tools
   to maintain your Python environment from being changed by other work on your
   computer.

.. _Python virtual environment: https://https://docs.python.org/3/library/venv.html

For Ubuntu, use:

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

   We've provided a script in the docs repo you can run to show what versions of
   the documentation building tools are installed and compare with the tool
   versions shown above. This tool will also verify you're using tool versions
   known to work together::

      docs/scripts/show-versions.py

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
      pymarkdownlnt             version: 0.9.21

Documentation Presentation Theme
********************************

Sphinx supports easy customization of the generated HTML documentation
appearance through the use of themes.  The ``sphinx-rtd-theme`` (Read The Docs)
theme is installed as part of the ``requirements.txt`` list above.  Tweaks to
the standard ``read-the-docs`` appearance are added by using CSS and JavaScript
customization found in ``doc/sphinx/_static``, and theme template overrides found in
``doc/sphinx/_templates``. If you change to another theme, you'll need to tweak
these customizations, not something for the faint of heart.

The Sphinx build system creates document cache information that attempts to
expedite documentation rebuilds, but occasionally can cause an unexpected error
or warning to be generated.  Doing a ``make clean`` to create a clean generation
environment and a ``make html`` again generally fixes these issues.


Run the Documentation Processors
********************************

The ``docs`` folder (with all the cloned sibling repos) have all the doc source files,
images, extra tools, and ``Makefile`` for generating a local copy of the OPEA
technical documentation. It's best to start with a clean doc-build environment
so use ``make clean`` to remove the ``_build`` working folder if it exists.  The
``Makefile`` creates the ``_build`` folder (if it doesn't exist) and copies all
needed files from these cloned repos into the ``_build/rst`` working folder.

Normally you'd have each repo checked out at the main branch before you run the
``make html`` step.  The doc build process uses the five repo's contents to
create the HTML site. If you're working on changes to documentation in a repo
and have those changes on a branch other than main, you can still generate the
documentation with that branch's changes -- this is how you can verify your
changes will not generate errors when your branch with changes is merged with
the main branch.

.. code-block:: bash

   cd ~/opea-project/docs
   make clean
   make html

Depending on your development system, it will take about a minute to collect and
generate the HTML content.  When done, you can view the HTML output in
``~/opea-project/docs/_build/html/index.html``.

As a convenience, there's a make target that will ``cd`` to the ``_build/html``
folder and run a local Python web server on port 8000:

.. code-block:: bash

   make server

Use your web browser to open the URL:  ``http://localhost:8000`` and wander
around your local site and view the results of your changes.  When
done, press :kbd:`ctrl-C` in your command-prompt window to stop the web server.

If things look good, you'd proceed to using git (``git add .``) to add and commit
(``git commit -s``) your changes, push those changes to your personal forked
repo (``git push origin <branchname>``) and submit a PR using the GitHub web
interface.

Publish Content
***************

If you have merge rights to the opea-project ``opea-project.github.io`` repo,
you can update the public project documentation found at
https://opea-project.github.io.

You'll need to do a one-time clone of the upstream repo (we publish
directly to the upstream repo rather than to a personal forked copy):

.. code-block:: bash

   cd ~/opea-project
   git clone https://github.com/opea-project/opea-project.github.io.git

Then, after you've verified the generated HTML produced by ``make html`` looks
good, you can push to the publishing site with:

.. code-block:: bash

   make publish

This uses git commands to synchronize the new content with what's
already published and will delete files in the publishing repo's
**latest** folder that are no longer needed. New or changed files from
the newly-generated HTML content are pushed to the GitHub pages
publishing repo (``opea-project.github.io.git``.  The public site at
https://opea-project.github.io will be automatically updated by the
`GitHub pages system <https://guides.github.com/features/pages/>`_,
typically within a few minutes.

Document Versioning
*******************

The https://opea-project.github.io site has a document version selector
at the top of the left nav panel.  The contents of this version
selector are defined in the ``conf.py`` sphinx configuration file,
specifically something like this:

.. code-block:: python
   :emphasize-lines: 5-6

   html_context = {
      'current_version': current_version,
      'docs_title': docs_title,
      'is_release': is_release,
      'versions': ( ("latest", "/latest/"),
                    ("1.0", "/1.0/"),
                  )
       }


As new versions of OPEA documentation are added, typically when a new release is
made, update this ``versions`` selection list to include the version number and
publishing folder.  Note that there's no direct selection to go to a newer
version from an older one, without going to ``latest`` first.

By default, documentation build and publishing both assume we're generating
documentation for the main branch and publishing to the ``/latest/`` area on
https://opea-project.github.io. When we're generating the documentation for a
tagged version (e.g., 1.0), check out that version of **all** the component
repos, and add some extra flags to the ``make`` commands:

.. code-block:: bash

   version=1.0
   for d in docs GenAIComps GenAIExamples GenAIEval GenAIInfra ; do
    cd ~/opea-project/$d
    git checkout $version
   done

   cd ~/opea-project/docs
   make clean
   make DOC_TAG=release RELEASE=$version html
   make DOC_TAG=release RELEASE=$version publish

.. _filter_expected:

Filter Expected Warnings
************************

Alas, there are some known issues with the Sphinx processing that generate
warnings.  We've added a post-processing filter on the output of the
documentation build process to check for "expected" warning messages in the generated
log output. By doing this, only "unexpected" messages will be reported and
cause the build process to fail with a message:

.. code-block:: console

   New errors/warnings found, please fix them:

followed by messages that weren't expected. Note that the file names shown in
the error/warning messages will be for files in the ``_build/rst`` folder
(copied from the repos). For example,

.. code-block:: console

   New errors/warnings found, please fix them:
   ==============================================

   /home/david/opea-project/docs/_build/rst/GenAIInfra/kubernetes-addons/Observability/README.md:5: WARNING: Non-consecutive header level increase; H1 to H4 [myst.header]
   /home/david/opea-project/docs/_build/rst/GenAIInfra/kubernetes-addons/Observability/README.md:111: WARNING: Non-consecutive header level increase; H3 to H6 [myst.header]

For files copied from repos other than the docs repo, you'll see the repo name
in the file path, for example, ``_build/rst/GenAIInfra`` with the path to
specific file with an issue. For example, the warnings shown here indicate
a heading level problem on lines 5 and 111 in
``GenAIInfra/kubernetes-addons/Observability/README.md``.

If you do a ``make html`` without first doing a ``make clean``, there may be
files left behind from a previous build that can cause some unexpected messages
to be reported. If things look suspicious, do a ``make clean;make html`` again.

If all messages were filtered away,
the build process will report as successful, reporting:

.. code-block:: console

   No new errors/warnings.

The output from the Sphinx build is processed by the Python script
``scripts/filter-known-issues.py`` together with a set of filter
configuration files in the ``.known-issues`` folder.  (This
filtering is done as part of the ``Makefile``.)

The filtering tool matches and removes whole line and multi-line patterns to
remove them.  Anything left behind is considered a message that should be
reported.  You can modify the filtering by adding or editing a conf file in the
``.known-issues`` folder, following the examples found there.

Multi-line patterns can get rather complex. We're not using any multi-line patterns in
the OPEA project. You can see complex examples in other open source projects
using this filtering script, such as pattern files in
`Project ACRN .known-issues <https://github.com/projectacrn/acrn-hypervisor/tree/master/doc/.known-issues>`_.

.. _reStructuredText: https://sphinx-doc.org/rest.html
.. _markdown: https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax
.. _Sphinx: https://sphinx-doc.org/
