require_relative '../analyze/analyzer'
require 'terminal-table'

module GitReviewer

  class AnalyzeOption
    attr_accessor :source
    attr_accessor :target
    attr_accessor :analyze_author
    attr_accessor :analyze_reviewer


    attr_accessor :analyzer

    def initialize(source, target, analyze_author, analyze_reviewer, verbose)
      @source = source
      @target = target
      @analyze_author = analyze_author
      @analyze_reviewer = analyze_reviewer
      @analyzer = Analyzer.new(source, target)
      Printer.verbose = verbose
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
      output_rows = []
      results.each do |item|
        file_ratio = item.file_count.to_f / total_file.to_f * 100
        line_ratio = item.line_count.to_f / total_line.to_f * 100
        output_rows << [item.name, item.file_count, "#{file_ratio.round(2)}%", item.line_count, "#{line_ratio.round(2)}%"]
      end

      table = Terminal::Table.new do |t|
        t.title = "Relevant authors involved in code changes"
        t.headings = ["Related Author", "File Count", "File Ratio", "Line Count", "Line Ratio"]
        t.rows = output_rows
      end
      puts table
      puts "\n"
    end

    def show_analyze_reviewer
      results = @analyzer.reviewer_results.values
      if results.size <= 0
        return
      end
      results = results.sort_by { |item| item.line_count }.reverse
      total_file = results.sum { |item| item.file_count }
      total_line = results.sum { |item| item.line_count }
      output_rows = []
      results.each do |item|
        file_ratio = item.file_count.to_f / total_file.to_f * 100
        line_ratio = item.line_count.to_f / total_line.to_f * 100
        output_rows << [item.name, item.file_count, "#{file_ratio.round(2)}%", item.line_count, "#{line_ratio.round(2)}%"]
      end

      table = Terminal::Table.new do |t|
        t.title = "Suggested reviewers for code changes."
        t.headings = ["Suggested Reviewer", "File Count", "File Ratio", "Line Count", "Line Ratio"]
        t.rows = output_rows
      end

      puts table
      puts "\n"
    end
  end
end
