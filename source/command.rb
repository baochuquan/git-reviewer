#!/usr/bin/ruby 

require_relative 'blame-tree'
require_relative 'blame-analyzer'
require_relative 'myers'

analyzer = BlameAnalyzer.new("master", "feature/practiceReward")
analyzer.analyzeSummary