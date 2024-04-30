require_relative 'blame_tree'

module GitReviewer

  class DiffFile
    UNKNOWN = 0     # 未知情况，理论上不存在
    DELETE = 1      # 删除文件
    ADD = 2         # 新增文件
    MODIFY = 3      # 修改文件

    attr_accessor :operation
    attr_accessor :file_name
    attr_accessor :diff_lines    #DiffLine

    attr_writer :binary

    def binary?
      @binary
    end

    def initialize(file_name, diff_lines, operation, binary)
      @file_name = file_name
      @diff_lines = diff_lines
      @operation = operation
      @binary = binary
    end

    def format_property
      result = ""
      case @operation
      when DiffFile::UNKNOWN
        result += "operation<UNKNOWN>"
      when DiffFile::DELETE
        result += "operation<DELETE>"
      when DiffFile::ADD
        result += "operation<ADD>"
      when DiffFile::MODIFY
        result += "operation<MODIFY>"
      end

      result += " "
      if binary?
        result += " binary<true>"
      else
        result += " binary<false>"
      end
      return result
    end

    def format_file_name
       return "file_name<#{file_name}>"
    end

    def format_line_diff
      result = ""
      diff_lines.each do |line|
        if line.operation == DiffLine::DELETE
          result += "\033[0;31m#{line.source_line.format_user} #{line.source_line.format_line} - #{line.source_line.description}\033[0m\n"
        elsif line.operation == DiffLine::ADD
          result += "\033[0;32m#{line.target_line.format_user} #{line.target_line.format_line} + #{line.target_line.description}\033[0m\n"
        else
          # TODO: @baocq
          # result += "#{line.target_line.format_user} #{line.target_line.format_line}   #{line.target_line.description}\n"
        end
      end
      return result
    end
  end

  class DiffLine
    UNCHANGE = 0    # 未变化
    DELETE = 1      # 删除行
    ADD = 2         # 新增行

    # 对于 UNCHANGE 操作，sLine 有值，tLine 有值
    # 对于 DELETE 操作，sLine 有值，tLine 无值
    # 对于 ADD 操作，sLine 无值，tLine 有值

    attr_accessor :source_line        # 原始行, BlameLine
    attr_accessor :target_line        # 目标行, BlameLine
    attr_accessor :operation

    def initialize(source_line, target_line, operation)
      @source_line = source_line
      @target_line = target_line
      @operation = operation
    end

    def s_line_number
      source_line.line
    end

    def t_line_number
      target_line.line
    end
  end
end
