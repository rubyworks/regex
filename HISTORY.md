# RELEASE HISTORY

## 1.1.1 / 2011-10-24

Maintenance release updates build configuration. This release
also adds a man-page and fixes one bug with single search output.

Changes:

* Modernize build configuration.
* Fix return value when no single match is found.
* Add man-page for help.


## 1.1.0 / 2010-10-12

This release adds a detailed output option, and corrects
a bug when using `--escape` with search and replace. It also
entails a pretty extensive under-the-hood overhaul of the
Extractor class. One consequence of this overhaul is that the
`--unxml` option has been deprecated until such time that it can
be reimplemented correctly.

Changes:

* Add --detail/-d output option.
* Fix isssue using escape with search and replace.
* Reimplement Extractor class.
* Deprecate `--unxml` option until implementation can be worked out.


## 1.0.0 / 2010-02-10

Initial release of Regex. Regex is a simple
commandline Regular Expression tool.

Changes:

* Happy Birthday

