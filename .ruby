--- 
name: regex
repositories: 
  public: git://github.com/proutils/regex.git
title: Regex
requires: 
- group: 
  - build
  name: syckle
  version: 0+
- group: 
  - test
  name: qed
  version: 0+
resources: 
  download: http://github.com/proutils/regex/downloads
  mail: http://groups.google.com/group/proutils/topics?hl=en
  docs: http://wiki.github.com/proutils/regex
  home: http://proutils.github.com/regex
  work: http://github.com/proutils/regex
pom_verison: 1.0.0
manifest: 
- .ruby
- bin/regex
- lib/regex/command.rb
- lib/regex/extractor.rb
- lib/regex/replacer.rb
- lib/regex/string.rb
- lib/regex/templates.rb
- lib/regex.rb
- lib/regex.yml
- qed/regex.rdoc
- qed/replacer.rdoc
- LICENSE
- README
- HISTORY
- VERSION
version: 1.1.0
description: Regex is a simple commmandline Regular Expression tool, that makes easy to search documents for content matches.
summary: Regex is a simple commmandline Regular Expression tool.
authors: 
- Thomas Sawyer
- Tyler Rick
created: 2006-05-09
