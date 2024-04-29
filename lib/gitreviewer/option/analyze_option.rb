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

      if analyze_author
        show_analyze_author
      end

      if analyze_reviewer
        show_analyze_reviewer
      end
    end

    def show_analyze_author
      results = @analyzer.author_results.values
      if results.size <= 0
        return
      end
      results = results.sort_by { |item| item.line_count }.reverse
      total_file = results.sum { |item| item.file_count }
      total_line = results.sum { |item| item.line_count }
      results.each do |item|
        file_ratio = item.file_count.to_f / total_file.to_f
        line_ratio = item.line_count.to_f / total_line.to_f
        puts "author => #{item.name}; file_count => #{item.file_count}; file_ratio => #{file_ratio.round(2)}; line_count => #{item.line_count}; line_ratio => #{line_ratio.round(2)}"
      end
    end

    def show_analyze_reviewer
      results = @analyzer.reviewer_results.values
      if results.size <= 0
        return
      end
      results = results.sort_by { |item| item.line_count }.reverse
      total_file = results.sum { |item| item.file_count }
      total_line = results.sum { |item| item.line_count }
      results.each do |item|
        file_ratio = item.file_count.to_f / total_file.to_f
        line_ratio = item.line_count.to_f / total_line.to_f
        puts "reviewer=> #{item.name}; file_count => #{item.file_count}; file_ratio => #{file_ratio.round(2)}; line_count => #{item.line_count}; line_ratio => #{line_ratio.round(2)}"
      end
    end
  end
end
