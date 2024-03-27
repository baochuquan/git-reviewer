#!/usr/bin/ruby 

require_relative 'blame/blame-tree'
require_relative 'blame/blame-builder'
require_relative 'utils/analyzer'
require_relative 'algorithm/myers'


analyzer = Analyzer.new("xlp/replace_clap_pag", "master")
# analyzer = Analyzer.new("feature/live", "master")
# analyzer = Analyzer.new("feature/changeEnLevel", "master")
# analyzer = Analyzer.new("release/5.8.x", "master")
analyzer.setupReviewers
analyzer.makeDecision
