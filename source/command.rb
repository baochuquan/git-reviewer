#!/usr/bin/ruby 

require_relative 'blame-tree'
require_relative 'blame-builder'
require_relative 'utils/analyzer'
require_relative 'myers'

# analyzer = BlameBuilder.new("feature/changeEnLevel", "master")
# analyzer.analyzeSummary

analyzer = Analyzer.new("feature/changeEnLevel", "master")
analyzer.summary

# myers = Myers.new("ABCABBA", "CBABAC")
# myers.myers("ABCABBA", "CBABAC")