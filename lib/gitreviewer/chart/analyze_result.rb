require 'set'

module GitReviewer
  class AnalyzeResult
    attr_accessor :name
    attr_accessor :file_count
    attr_accessor :line_count

    attr_accessor :file_names

    def initialize(name)
      @name = name
      @file_count = 0
      @line_count = 0
      @file_names = Set.new
    end

    def add_file_name(name)
      @file_names.add(name)
      @file_count = file_names.count
    end

    def add_file_count(count)
      @ile_count += count
    end

    def add_line_count(count)
      @line_count += count
    end
  end
end
