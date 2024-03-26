#!/usr/bin/ruby 

require_relative 'blame/blame-tree'
require_relative 'blame/blame-builder'
require_relative 'utils/analyzer'
require_relative 'algorithm/myers'

analyzer = Analyzer.new("feature/changeEnLevel", "master")
analyzer.summary
