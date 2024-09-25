.. _doc_guidelines:

Documentation Guidelines
########################

OPEA Project content is written using the `markdown`_ (``.md``) with `MyST extensions`_
and `reStructuredText`_ markup language (``.rst``) with `Sphinx extensions`_, and processed
using `Sphinx`_ to create a formatted stand-alone website.  Developers can
view this content either in its raw form as ``.md`` and ``.rst`` markup files, or
build the documentation locally following the :ref:`opea_doc_generation` instructions.
The HTML content can then be viewed using a web browser. These ``.md`` and
``.rst`` files are maintained in the project's GitHub repos and processed to
create the `OPEA Project documentation`_ website.

.. note:: While GitHub supports viewing `.md` and `.rst` content with your browser on the
   `github.com` site, markdown and reST extensions are not recognized there, so the
   best viewing experience is through the `OPEA Project documentation`_ github.io
   website. The github.io site also provides navigation and searching that makes
   it easier to find and read what you're looking for.

You can read details about `reStructuredText`_ and `Sphinx extensions`_, and
`markdown`_ and `MyST extensions`_ from their respective websites.

.. _MyST extensions: https://mystmd.org/guide/quickstart-myst-markdown
.. _Sphinx extensions: https://www.sphinx-doc.org/en/stable/contents.html
.. _reStructuredText: http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html
.. _Sphinx: https://www.sphinx-doc.org
.. _Sphinx Inline Markup: https://www.sphinx-doc.org/en/master/usage/restructuredtext/roles.html
.. _OPEA Project documentation:  https://opea-project.github.io
.. _markdown: https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax

This document provides a quick reference for commonly used markdown and reST
with MyST and Sphinx-defined directives and roles used to create the documentation
you're reading. It also provides best-known-methods for working with a mixture
of reStructuredText and markdown.

Markdown vs. RestructuredText
*****************************

Both markdown and ReStructureText (reST) let you create individual documentation files that
GitHub can render when viewing them in your browser on github.com. Markdown is
popular because of it's familiarity with developers and is the default markup
language for StackOverflow, Reddit, GitHub, and others.  ReStructuredText came
from the Python community in 2001 and became noticed outside that
community with the release of Sphinx in 2008.  These days, reST is supported by GitHub
and major projects use it for their documentation, including the Linux kernel,
OpenCV and LLVM/Clang.

ReStructuredText is more fully-featured, much more standardized and uniform, and
has built-in support for extensions.  The markdown language has no standard way
to implement complete documentation systems and doesn't have a standard extension
mechanism, which leads to many different "flavors" of markdown. If you stick to
the core and common markdown syntax (headings, paragraphs, lists, and such),
using markdown is just fine.  However, slipping in raw HTML to do formatting
(such as centering) or using HTML for tables creates problems when publishing to the
https://opea-project.github.io site. The MyST parser provides extensions to
markdown that integrated well with Sphinx, so we use this as a bridge for the
markdown content within the OPEA project.


Within the OPEA documentation, we use both markdown and reST files for the
documentation "leaves".  We rely on reST for the documentation organization trunk and
branches, through the use of the reST ``toctree`` directives.

Documentation Organization
**************************

Documentation is maintained and updated the same as the project's code within
the opea-project GitHub repos. There are many ``README.md`` and other markdown files within the various
repos along with the other files for those components. This is good because it
keeps the relevant documentation and code for that component together.

We use the ``docs`` repo to organize the presentation of all these ``README.md``
files, along with other project related documents that are maintained in the
``docs`` repo.  The root of the generated documentation starts with the
``docs/index.rst`` file that starts off the organizational structure that's
shown as the left navigation in the generated HTML site at
https://opea-project.github.io.  That ``index.rst`` file uses a ``toctree``
directive to point to other documents that may include additional ``toctree``
directives of their own, ultimately collecting all the content into an
organizational structure you can navigate.

Ultimately every document file (``.md`` and ``.rst``) in the project must appear
in the ``toctree`` hierarchy. An orphan document file will be flagged by Sphinx
as not included in a toctree directive.

Headings
********

.. tabs::

   .. group-tab:: reST

        In reST, document sections are identified through their heading titles, indicated with
        an underline below the title text.  (While reST allows use of both and
        overline and matching underline to indicate a heading, we use only an
        underline indicator for headings.)  For consistency in our documentation, we
        define the order of characters used to indicate the nested levels in the
        table of contents:

        * Use ``#`` for the Document title underline character (H1)
        * Use ``*`` for the First sub-section heading level (H2)
        * Use ``=`` for the Second sub-section heading level (H3)
        * Use ``-`` for the Third sub-section heading level (H4)

        Additional heading-level depth is discouraged, but if needed, use ``%``
        (H5), ``+`` (H6), and ``@`` (H7).

        The heading underline must be at least as long as the title it's under.

        Here's an example of nested heading levels and the appropriate
        underlines to use:

        .. code-block:: rest

           Document Title heading
           ######################

           Section 1 heading
           *****************

           Section 2 heading
           *****************

           Section 2.1 heading
           ===================

           Section 2.1.1 heading
           ---------------------

           Section 2.2 heading
           ===================

           Section 3 heading
           *****************


   .. group-tab:: markdown

      In markdown, headings are indicated as a line beginning with a ``#``
      character, with additional ``#`` characters indicating a deeper heading
      level, e.g., ``#`` for H1 (title), ``##`` for H2 headings, ``###`` for H3
      headings, and so on.)

      * The ``#`` character for a heading must be the first character on the
        line, then a space, followed by the heading.  For example::

           # My Document's Title

           Some content goes here.

           ## First H2 heading

           Some more content

      * There must be only one ``#`` H1 heading at the beginning of the document
        indicating the document's title.
      * You must not skip heading levels on the way down in the document
        hierarchy, e.g., do not go from a H1 ``#`` to an H3 ``###`` without an
        intervening H2 ``##``. You may skip heading levels on the way back up,
        for example, from an H4 ``####`` back up to an H2 ``##`` as appropriate.

      Sphinx will complain if it finds multiple H1 headings or if you skip a
      heading level.


Content Highlighting
********************

Some common reST and markdown inline markup samples:

* one asterisk: ``*text*`` for emphasis (*italics*),
* two asterisks: ``**text**`` for strong emphasis (**boldface**)

.. tabs::

   .. group-tab:: reST

      * two back quotes: ````text```` for ``inline code`` samples.

      ReST rules for inline markup try to be forgiving to account for common
      cases of using these marks.  For example, using an asterisk to indicate
      multiplication, such as ``2 * (x + y)`` will not be interpreted as an
      unterminated italics section.

   .. group-tab:: markdown

      * one back quote: ```text``` for ``inline code`` samples.

For inline markup, the characters between
the beginning and ending characters must not start or end with a space,
so ``*this is italics*``, (*this is italics*)  while ``* this isn't*``
(* this isn't*) because of that extra space after the first asterisk.

If an asterisk or back quote appears in running text and could be confused
with inline markup delimiters, you can eliminate the confusion by adding a
backslash (``\``) before it.


Lists
*****

For bullet lists, place an asterisk (``*``) or hyphen (``-``) at the start of
a paragraph and indent continuation lines with two spaces.

The first item in a list (or sublist) must have a blank line before it and
should be indented at the same level as the preceding paragraph (and not
indented itself).

For numbered lists
start with a ``1.`` or ``a.`` for example, and continue with autonumbering by
using a ``#`` sign and a ``.`` as used in the first list item.
Indent continuation lines with spaces to align with the text of first
list item:

It's important to maintain the indentation of content under a list so in the
generated HTML, the content looks like it's part of that list and not a new
paragraph outside of that list.

For example, compare this:

-----

* Here's a bullet list item

Here's a paragraph that should be part of that first bullet list item's content.

* Here's a second bullet list item

-----

Notice how that middle paragraph is out-dented from the bullet list compared
with this next example where it's not (yes, it's subtle):

-----

* Here's a bullet list item

  Here's a paragraph that does look like it's part of that first bullet list item's content because it's indented in the source.

* Here's a second bullet list item

-----


.. code-block:: rest

   * This is a bulleted list.
   * It has two items, the second
     item and has more than one line of text.  Additional lines
     are indented to the first character of the
     text of the bullet list.

   1. This is a new numbered list. If there wasn't a blank line before it,
      it would be a continuation of the previous list (or paragraph).
   #. It has two items too.

   a. This is a numbered list using alphabetic list headings
   #. It has three items (and uses autonumbering for the rest of the list)
   #. Here's the third item.  Use consistent punctuation on the list
      number.

   #. This is an autonumbered list (default is to use numbers starting
      with 1).

      #. This is a second-level list under the first item (also
         autonumbered).  Notice the indenting.
      #. And a second item in the nested list.
   #. And a second item back in the containing list.  No blank line
      needed, but it wouldn't hurt for readability.

.. tabs::

   .. group-tab:: reST

      Definition lists (with one or more terms and their definition) are a
      convenient way to document a word or phrase with an explanation.  For example,
      this reST content:

      .. code-block:: rest

         The Makefile has targets that include:

         ``html``
            Build the HTML output for the project

         ``clean``
            Remove all generated output, restoring the folders to a
            clean state.

      Would be rendered as:

         The Makefile has targets that include:

         html
            Build the HTML output for the project

         clean
            Remove all generated output, restoring the folders to a
            clean state.

   .. group-tab:: markdown

         Definition lists aren't directly supported by markdown.

Multi-Column Lists
******************

.. tabs::

   .. group-tab:: reST

      In reST, if you have a long bullet list of items, where each item is short, you can
      indicate that the list items should be rendered in multiple columns with a
      special ``.. rst-class:: rst-columns`` directive.  The directive will apply to
      the next non-comment element (for example, paragraph) or to content indented under
      the directive. For example, this unordered list::

         .. rst-class:: rst-columns

         * A list of
         * short items
         * that should be
         * displayed
         * horizontally
         * so it doesn't
         * use up so much
         * space on
         * the page

      would be rendered as:

      .. rst-class:: rst-columns

         * A list of
         * short items
         * that should be
         * displayed
         * horizontally
         * so it doesn't
         * use up so much
         * space on
         * the page

      A maximum of three columns will be displayed if you use ``rst-columns``
      (or ``rst-columns3``), and two columns for ``rst-columns2``. The number
      of columns displayed can be reduced based on the available width of the
      display window, reducing to one column on narrow (phone) screens if necessary.

   .. group-tab:: markdown

         Multi-column lists aren't directly supported by markdown.

Tables
******

There are a few ways to create tables, each with their limitations or quirks.
`Grid tables
<http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html#grid-tables>`_
offer the most capability for defining merged rows and columns (where content
spans multiple rows or columns, but are hard to maintain because the grid
characters must be aligned throughout the table.  They are supported in both
reST and markdown::

   +------------------------+------------+----------+----------+
   | Header row, column 1   | Header 2   | Header 3 | Header 4 |
   | (header rows optional) |            |          |          |
   +========================+============+==========+==========+
   | body row 1, column 1   | column 2   | column 3 | column 4 |
   +------------------------+------------+----------+----------+
   | body row 2             | ...        | ...      | you can  |
   +------------------------+------------+----------+ easily   +
   | body row 3 with a two column span   | ...      | span     |
   +------------------------+------------+----------+ rows     +
   | body row 4             | ...        | ...      | too      |
   +------------------------+------------+----------+----------+

This example would render as:

+------------------------+------------+----------+----------+
| Header row, column 1   | Header 2   | Header 3 | Header 4 |
| (header rows optional) |            |          |          |
+========================+============+==========+==========+
| body row 1, column 1   | column 2   | column 3 | column 4 |
+------------------------+------------+----------+----------+
| body row 2             | ...        | ...      | you can  |
+------------------------+------------+----------+ easily   +
| body row 3 with a two column span   | ...      | span     |
+------------------------+------------+----------+ rows     +
| body row 4             | ...        | ...      | too      |
+------------------------+------------+----------+----------+

.. tabs::

   .. group-tab:: reST

      For reST, `List tables <http://docutils.sourceforge.net/docs/ref/rst/directives.html#list-table>`_
      are much easier to maintain, but don't support row or column spans::

         .. list-table:: Table title
            :widths: 15 20 40
            :header-rows: 1

            * - Heading 1
              - Heading 2
              - Heading 3
            * - body row 1, column 1
              - body row 1, column 2
              - body row 1, column 3
            * - body row 2, column 1
              - body row 2, column 2
              - body row 2, column 3

      This example would render as:

      .. list-table:: Table title
         :widths: 15 20 40
         :header-rows: 1

         * - Heading 1
           - Heading 2
           - Heading 3
         * - body row 1, column 1
           - body row 1, column 2
           - body row 1, column 3
         * - body row 2, column 1
           - body row 2, column 2
           - body row 2, column 3

      The ``:widths:`` parameter lets you define relative column widths.  The
      default is equal column widths. If you have a three-column table and you
      want the first column to be half as wide as the other two equal-width
      columns, you can specify ``:widths: 1 2 2``.  If you'd like the browser
      to set the column widths automatically based on the column contents, you
      can use ``:widths: auto``.

   .. group-tab:: markdown

      Markdown also supports a more free-form table syntax where the rigid box
      alignment is greatly simplified as explained in
      `markdown tables <https://www.markdownguide.org/extended-syntax/#tables>`_.
      Use three or more hyphens ``---`` to denote each column's header, and use
      pipes ``|`` to separate each column.  For compatibility you should also
      add a pipe on both ends of the row::

         | heading 1 | heading 2 | heading 3 |
         |---|---|---|
         |row 1 column 1 | row 1 column 2 | yes, it's row 1 column 3|
         |row 2 col 1 | row 2 column 2 | row 2 col 3 |

      That would be rendered as:

      .. include:: mdtable.txt
         :parser: myst_parser.sphinx_


File Names and Commands
***********************

.. tabs::

   .. group-tab:: reST

      Sphinx extends reST by supporting additional inline markup elements (called
      "roles") used to tag text with special meanings and enable output formatting.
      (You can refer to the `Sphinx Inline Markup`_ documentation for the full
      list).

      For example, there are roles for marking :file:`filenames`
      (``:file:`name```) and command names such as :command:`make`
      (``:command:`make```).  You can also use the \`\`inline code\`\`
      markup (double backticks) to indicate a ``filename``.

      Don't use items within a single backtick, for example ```word```. Instead
      use double backticks: ````word````.

   .. group-tab:: markdown

      MyST extends markdown by supporting additional inline markup elements
      (called "roles") used to tag text with special meanings and enable output
      formatting.

Branch-Specific File Links
**************************

You can add a link in the documentation to a specific file in the GitHub tree.
Be sure the link points to the branch for that version of the documentation. For
example, links in the v0.8 release of the documentation should be to files in
the v0.8 branch. Do not link to files in the main branch because files in that
branch could change or even be deleted after the release is made.

In reST, to make this kind of file linking possible, use a special role that
creates a hyperlink to that file in the branch currently checked out.

.. note:: It's assumed that the checked out version of the **docs** repo when we
   generate the HTML documentation is the same tagged version for all the repos
   we want to reference.

For example, a GitHub
link to the reST file used to create this document can be generated
using ``:docs_blob:`developer-guides/doc_guidelines```, which will
appear as :docs_blob:`developer-guides/doc_guidelines.rst`, a link to
the "blob" file in the GitHub repo as displayed by GitHub. There's also an
``:docs_raw:`developer-guides/doc_guidelines.rst``` role that will link
to the "raw" uninterpreted file,
:docs_raw:`developer-guides/doc_guidelines.rst`. Click these links
to see the difference.

If you don't want the whole path to the file name to
appear in the text, you use the usual linking notation to define what link text
is shown, for example, ``:docs_blob:`Guidelines <developer-guides/doc_guidelines.rst>```
would show up as simply :docs_blob:`Guidelines <developer-guides/doc_guidelines.rst>`.

.. _internal-linking:

Internal Cross-Reference Linking
********************************

.. tabs::

   .. group-tab:: reST

      Traditional reST links are supported only within the current file using the
      notation:

      .. code-block:: rest

         refer to the `internal-linking`_ documentation

      which renders as,

         refer to the `internal-linking`_ documentation

      Note the use of a trailing underscore indicates an **outbound link**. In this
      example, the label was added immediately before a heading, so the text that's
      displayed is the heading text itself.

      With Sphinx, we can create link-references to any tagged text within
      the project documentation.

      Target locations within documents are defined with a label directive:

         .. code-block:: rst

            .. _my label name:

      Note the leading underscore indicating an **inbound link**. The content
      immediately following this label is the target for a ``:ref:`my label name```
      reference from anywhere within the documentation set. The label **must** be
      added immediately before a heading so that there's a natural phrase to show
      when referencing this label (for example, the heading text).

      This directive is also used to define a label that's a reference to a URL:

      .. code-block:: rest

         .. _Hypervisor Wikipedia Page:
            https://en.wikipedia.org/wiki/Hypervisor

      To enable easy cross-page linking within the site, each file should have a
      reference label before its title so that it can be referenced from another
      file.

      .. note:: These reference labels must be unique across the whole site, so generic
         names such as "samples" or "introduction" should be avoided.

      For example, the top of this document's ``.rst`` file is:

      .. code-block:: rst

         .. _doc_guidelines:

         Documentation Guidelines
         ########################

      Other ``.rst`` documents can link to this document using the
      ``:ref:`doc_guidelines``` tag, and it will appear as :ref:`doc_guidelines`.
      This type of internal cross-reference works across multiple files. The link
      text is obtained from the document source, so if the title changes, the link
      text will automatically update as well.

      There may be times when you'd like to change the link text that's shown in the
      generated document.  In this case, you can specify alternate text using
      ``:ref:`alternate text <doc_guidelines>``` (renders as
      :ref:`alternate text <doc_guidelines>`).

      Linking from a reST document to a markdown document is done using the reST
      ``:doc:`` role, and using the path to the markdown file leaving off the
      ``.md`` file extension.  For example::

         Refer to the :doc:`/GenAIExamples/supported_examples` list for details.

      Note that all the markdown files from all the repos are available with
      this syntax because we copy all those files into the doc building folder
      under a top-level directory with that repo's name.  Markdown files in the
      docs repo don't use the ``docs`` repo name as the path root but use ``/``
      instead.  So to link to the contribution guide markdown file found in the
      docs repo community directory you would use ``:doc:`Contribution Guide
      </community/CONTRIBUTING>```. Notice you can change the link text using
      the normal reST role syntax shown here.

   .. group-tab:: markdown

      Markdown supports linking to other documents using the ``[link text](link path)``.
      For example to link to a document within the same repo, a relative path is
      used::

          Refer to [Kubernetes deployment](./kubernetes/intel/README_gmc.md)

      That reference is rendered as a reference to the README_gmc.html found in
      the directory ``kubernetes/intel`` relative to the document doing the
      linking.

      References to documents in other repos within the OPEA project are made
      using an URL to the document in the github.com repo as it would be found
      in a web browser.  For example, from a markdown document in the
      GenAIExamples repo referencing a document in the GenAIInfra repo::

         Refer to the [DocSum helm chart](https://github.com/opea-project/GenAIInfra/tree/main/helm-charts/docsum/README.md)
         for instructions on deploying DocSum into Kubernetes on Xeon & Gaudi.

      That reference would be rendered into a reference to the
      https://opea-project.github.io/GenAIInfra/helm-charts/docsum/README.html
      document within the github.io website.

      Markdown supports linking to a reST document by using the Myst syntax that
      mimics the way reST documents link to each other using the ``:ref:`` role
      and using the label at the beginning of the reST document.  For example::

         {ref}`ChatQnA Example Deployment Options <chatqna-example-deployment>`

      The ChatQnA example deployment options document found at
      ``examples/ChatQnA/deploy/index.rst`` has that
      ``chatqna-example-deployment`` label at the top we can
      reference instead of knowing the path to the document.

Non-ASCII Characters
********************

You can insert non-ASCII characters such as a Trademark symbol (|trade|) by
using the notation ``|trade|``.  (It's also allowed to use the UTF-8
characters directly.) Available replacement names are defined in an include
file used during the Sphinx processing of the reST files.  The names of these
replacement characters are the same as those used in HTML entities to insert
special characters such as \&trade; and are defined in the file
``sphinx_build/substitutions.txt`` as listed here:

.. literalinclude:: ../sphinx/substitutions.txt
   :language: rst

We've kept the substitutions list small but you can add others as needed by
submitting a change to the ``substitutions.txt`` file.

Include Content from Other Files

You can directly incorporate a document fragment from another file into your reST or
markdown content by using an ``include`` directive.

.. important:: Be aware that references to content within the included content
   are relative to the file doing the including. For example a relative reference
   to an image must be correct from the point-of-view of the file doing the
   inclusion, not the point-of-view of the included file.  Also, the included
   file must be appropriate in the current document's context at the point of
   the directive.  If an included document fragment contains section structure,
   the title structure must match and be consistent in context.

.. tabs::

   .. group-tab:: reST

      In reST, you incorporate content from another file using an include
      directive. Unless options are given, the included file is parsed in the
      current document's context::

         Here is some text in the reST document.

         .. include::  path/to/file

         And now we're back to the original document after the content in the
         included file, as if that content were directly in the current file.

      You can use options to alter how the included file is processed:

      \:code\: language
         The included content is treated as a ``code-block`` with ``language``
         highlighting.

      \:parser\: text
         By default, the included content is parsed the same as the current
         document (e.g., rst). This option specifies another parser such as
         ``:parser: myst_parser.sphinx_`` if the included file is markdown.

      \:start-after\: text
         Only the content after the first occurrence of the specified ``text`` in
         the external file will be included.

      \:end-before\:
         Only the content before the first occurrence of the specified ``text``
         in the external file will be included.

      These and other options described in the `docutils include directive <https://docutils.sourceforge.io/docs/ref/rst/directives.html#including-an-external-document-fragment>`_
      documentation.

   .. group-tab:: markdown

         MyST directives can be used to incorporate content from another file
         into the current document as if it were part of the current document::

            ```{include} relativepath/to/file
            ```

        The ``relativepath/to/file`` can starts with a ``/`` to indicate a path
        starting from the root of the document directory tree (not the root of
        the underlying file system).  You can reference files outside the
        document tree root using ``../../`` syntax to get to the file.

        You can include an external file and show it as if it were a codeblock
        by using the ``literalinclude`` directive::

           ```{literalinclude} relativepath/to/file
           ```

        You can include reST content, interpreted as reST by using the
        ``eval-rst`` directive an using the reST syntax and options for an
        ``include`` directive, such as::

           ```{eval-rst}
           .. include:: path/to-file
              :start-after: <start include marker>
              :end-before: <end include marker>
           ```


Code and Command Examples
*************************

.. tabs::

   .. group-tab:: reST

        Use the reST ``code-block`` directive to create a highlighted block of
        fixed-width text, typically used for showing formatted code or console
        commands and output.  Smart syntax highlighting is also supported (using the
        Pygments package). You can also directly specify the highlighting language.
        For example:

        .. code-block:: rest

           .. code-block:: c

              struct _k_object {
                 char *name;
                 u8_t perms[CONFIG_MAX_THREAD_BYTES];
                 u8_t type;
                 u8_t flags;
                 u32_t data;
              } __packed;

        Note that there is a blank line between the ``code-block`` directive and the
        first line of the code-block body, and the body content is indented three
        spaces (to the first non-blank space of the directive name).

        This example would render as:

        .. code-block:: c

          struct _k_object {
             char *name;
             u8_t perms[CONFIG_MAX_THREAD_BYTES];
             u8_t type;
             u8_t flags;
             u32_t data;
          } __packed;


        You can specify other languages for the ``code-block`` directive, including
        ``c``, ``python``, and ``rst``, and also ``console``, ``bash``, or ``shell``.
        If you want no syntax highlighting, specify ``none``. For example:

        .. code-block:: rest

           .. code-block:: none

              This block of text would be styled with a background
              and box, but with no syntax highlighting.

        Would display as:

        .. code-block:: none

          This block of text would be styled with a background
          and box, but with no syntax highlighting.

        There's a shorthand for writing code blocks, too: end the introductory
        paragraph with a double colon (``::``) and indent the code block content
        by three spaces.  On output, only one colon will appear.

        .. note:: The highlighting package makes a best guess at the type of content
           in the block, which can lead to odd
           highlighting in the generated output.

   .. group-tab:: markdown

      In markdown, fenced code blocks are used to define code blocks.  Use three
      backticks ``````` on the lines before and after the code block, for
      example:

      .. code-block:: none

         ```
         {
            "firstName": "John",
            "lastName": "Smith",
            "age": 25
         }
         ```

      The rendered output would look like this:

      .. code-block:: none

         {
            "firstName": "John",
            "lastName": "Smith",
            "age": 25
         }

      Syntax highlighting is also supported for fenced code blocks by specifying
      a language next to the backticks before the fenced code block:

      .. code-block:: none

         ```json
         {
            "firstName": "John",
            "lastName": "Smith",
            "age": 25
         }
         ```

      The rendered output would look like this:

      .. code-block:: json

         {
            "firstName": "John",
            "lastName": "Smith",
            "age": 25
         }

      TODO: add the list of supported languages.

Images
******

The image file name specified is relative to the document source file. We
recommend putting images into an ``images`` folder where the document source
is found.  The usual image formats handled by a web browser are supported:
JPEG, PNG, GIF, and SVG.  Keep the image size only as large as needed,
generally at least 500 px wide but no more than 1000 px, and no more than
250 KB unless a particularly large image is needed for clarity.

You can also specify an URL to an image file if needed.

.. tabs::

   .. group-tab:: reST

        In reST, images are placed the document using an image directive::

           .. image:: ../images/opea-horizontal-color-w200.png
              :align: center
              :alt: alt text for the image

        or if you'd like to add an image caption, use the figure directive::

            .. figure:: ../images/opea-horizontal-color-w200.png
               :alt: image description

               Caption for the figure

   .. group-tab:: markdown

In markdown, images are placed in documentation using this syntax::

          ![OPEA Logo](../images/opea-horizontal-color-w200.png)



Tabs, Spaces, and Indenting
***************************

Indenting is significant in reST file content, and using spaces is preferred.
Extra indenting can (unintentionally) change the way content is rendered, too.
For lists and directives, indent the content text to the first non-blank space
in the preceding line.  For example:

.. code-block:: rest

   * List item that spans multiple lines of text
     showing where to indent the continuation line.

   1. And for numbered list items, the continuation
      line should align with the text of the line above.

   .. code-block::

      The text within a directive block should align with the
      first character of the directive name.

Keep the line length for documentation fewer than 80 characters to make it
easier for reviewing in GitHub. Long lines due to URL references are an
allowed exception.

Background Colors
*****************

We've defined some CSS styles for use as background colors for paragraphs.
These styles can be applied using the ``.. rst-class`` directive using one of
these style names.  You can also use the defined ``centered`` style to place the
text centered within the element, useful for centering text within a table cell
or column span:

.. rst-class:: bg-opea-lightorange centered

   \.\. rst-class:: bg-opea-lightorange centered

.. rst-class:: bg-opea-darkorange centered

   \.\. rst-class:: bg-opea-darkorange centered

Drawings
********

.. tabs::

   .. group-tab:: reST

      In reST, we've included the ``graphviz`` Sphinx extension to enable that
      text description language to render drawings.  For more information, see
      :ref:`graphviz-examples`.

      We've also included an extension providing ``mermaid`` support that also enables
      that text description language to render drawings using::

         .. mermaid::

            graph LR;
              A--> B & C;
              B--> A & C;
              C--> A & B;

      This will be rendered into this graph drawing:

      .. mermaid::

         graph LR;
           A--> B & C;
           B--> A & C;
           C--> A & B;

      See the `Mermaid User Guide <https://mermaid.js.org/intro/getting-started.html>`_ for more
      information.

   .. group-tab:: markdown

      In markdown, we've included the MyST ``mermaid`` extensions to enable that text
      description language to render drawings using::

         ```{mermaid}
         graph LR;
           A--> B & C & D;
           B--> A & E;
           C--> A & E;
           D--> A & E;
           E--> B & C & D;
         ```

      This will be rendered into this graph drawing:

      .. mermaid::

         graph LR;
           A--> B & C & D;
           B--> A & E;
           C--> A & E;
           D--> A & E;
           E--> B & C & D;

      See the `Mermaid User Guide <https://mermaid.js.org/intro/getting-started.html>`_ for more
      information.

Alternative Tabbed Content
**************************

In reST, instead of creating multiple documents with common material except for some
specific sections, you can write one document and provide alternative content
to the reader via a tabbed interface. When the reader clicks a tab, the
content for that tab is displayed. For example::

   .. tabs::

      .. tab:: Apples

         Apples are green, or sometimes red.

      .. tab:: Pears

         Pears are green.

      .. tab:: Oranges

         Oranges are orange.

will display as:

.. tabs::

   .. tab:: Apples

      Apples are green, or sometimes red.

   .. tab:: Pears

      Pears are green.

   .. tab:: Oranges

      Oranges are orange.

Tabs can also be grouped so that changing the current tab in one area
changes all tabs with the same name throughout the page.  For example:

.. tabs::

   .. group-tab:: Linux

      Linux Line 1

   .. group-tab:: macOS

      macOS Line 1

   .. group-tab:: Windows

      Windows Line 1

.. tabs::

   .. group-tab:: Linux

      Linux Line 2

   .. group-tab:: macOS

      macOS Line 2

   .. group-tab:: Windows

      Windows Line 2

In this latter case, we're using a ``.. group-tab::`` directive instead of
a ``.. tab::`` directive.  Under the hood, we're using the `sphinx-tabs
<https://github.com/djungelorm/sphinx-tabs>`_ extension that's included
in the OPEA docs (requirements.txt)  setup.  Within a tab, you can have most
any content *other than a heading* (code-blocks, ordered and unordered
lists, pictures, paragraphs, and such).

Instruction Steps
*****************

In reST, a numbered instruction steps style makes it easy to create tutorial guides
with clearly identified steps. Add the ``.. rst-class:: numbered-step``
directive immediately before a second-level heading (by project convention, a
heading underlined with asterisks ``******``, and it will be displayed as a
numbered step, sequentially numbered within the document.  (Second-level
headings without this ``rst-class`` directive will not be numbered.)
For example::

   .. rst-class:: numbered-step

   Put your right hand in
   **********************

.. rst-class:: numbered-step

First Instruction Step
**********************

This is the first instruction step material.  You can do the usual paragraph
and pictures as you'd use in normal document writing. Write the heading to be
a summary of what the step is (the step numbering is automated so you can move
steps around easily if needed).

.. rst-class:: numbered-step

Second Instruction Step
***********************

This is the second instruction step.

.. note:: As implemented,
   only one set of numbered steps is intended per document and the steps
   must be level 2 headings.


Documentation Generation
************************

For instructions on building the documentation, see :ref:`opea_doc_generation`.
