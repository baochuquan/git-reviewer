require_relative '../utils/analyzer'

module GitReviewer

  class AnalyzeOption
    attr_accessor :source
    attr_accessor :target
    attr_accessor :analyze_author
    attr_accessor :analyze_reviewer
    attr_accessor :verbose

    attr_accessor :analyzer

    def initialize(source, target, analyze_author, analyze_reviewer, verbose)
      @source = source
      @target = target
      @analyze_author = analyze_author
      @analyze_reviewer = analyze_reviewer
      @verbose = verbose
      @analyzer = Analyzer.new(source, target)
    end

    def execute
      @analyzer.execute
    end
  end
end
