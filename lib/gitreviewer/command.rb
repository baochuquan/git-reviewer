#!/usr/bin/ruby 

require_relative 'blame/blame-tree'
require_relative 'blame/blame-builder'
require_relative 'utils/analyzer'
require_relative 'algorithm/myers'


module GitReviewer
    require 'claide'
    require 'gitreviewer/blame/blame-tree'
    require 'gitreviewer/blame/blame-builder'
    require 'gitreviewer/utils/analyzer'
    require 'gitreviewer/algorithm/myers'

    class Command < CLAide::Command 
        self.abstract_command = true

        self.description = <<-DESC
            git-reviewer is ...TODO
        DESC

        self.command = 'git-reviewer'

        def initialize(argv)
            # @verbose = argv.flag?('verbose', true)
            super
        end

        def run
            analyzer = Analyzer.new("feature/changeEnLevel", "master")
            analyzer.setupReviewers
            analyzer.makeDecision
        end
    end
end 

# analyzer = Analyzer.new("xlp/replace_clap_pag", "master")
# analyzer = Analyzer.new("feature/live", "master")
# analyzer = Analyzer.new("release/5.8.x", "master")

