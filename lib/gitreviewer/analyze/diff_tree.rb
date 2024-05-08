require 'gitreviewer/analyze/blame_tree'
require 'gitreviewer/utils/printer'
require 'terminal-table'

module GitReviewer

  class DiffFile
    UNKNOWN = 0     # 未知情况，理论上不存在
    DELETE = 1      # 删除文件
    ADD = 2         # 新增文件
    MODIFY = 3      # 修改文件

    attr_accessor :operation
    attr_accessor :file_name
    attr_accessor :diff_lines

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

    def print_meta_info
      rows = [
        ["filename", file_name],
        ["operation", format_operation],
        ["binary", binary?]
      ]
      table = Terminal::Table.new do |t|
        t.rows = rows
      end
      Printer.verbose_put table
    end

    def format_property
      result = ""
      case @operation
      when DiffFile::UNKNOWN
        result += "operation: UNKNOWN \n"
      when DiffFile::DELETE
        result += "operation: DELETE \n"
      when DiffFile::ADD
        result += "operation: ADD \n"
      when DiffFile::MODIFY
        result += "operation: MODIFY \n"
      end

      if binary?
        result += "binary: true \n"
      else
        result += "binary: false \n"
      end
      return result
    end

    def format_operation
      case @operation
      when DiffFile::UNKNOWN
        return "UNKNOWN"
      when DiffFile::DELETE
        return "DELETE"
      when DiffFile::ADD
        return "ADD"
      when DiffFile::MODIFY
        return "MODIFY"
      end
    end

    def format_file_name
       return "filename: #{file_name}\n"
    end

    def format_line_diff
      name_max_length = 0
      result = []

      diff_lines.each_with_index do |line, index|
        name_max_length = [name_max_length, line.format_user.length].max

        if line.is_unchange
          if result.size == 0 || !result.last.is_unchange
            result.append(line)
          end
        else
          result.append(line)
        end
      end

      name_max_length += 2

      format_content = ""
      result.each do |line|
        if line.operation == DiffLine::DELETE
          format_content += "\033[0;31m#{line.source_line.user.rjust(name_max_length)} #{line.source_line.format_line} - #{line.source_line.description}\033[0m\n"
        elsif line.operation == DiffLine::ADD
          format_content += "\033[0;32m#{line.target_line.user.rjust(name_max_length)} #{line.target_line.format_line} + #{line.target_line.description}\033[0m\n"
        else
          format_content += "...\n"
        end
      end

      return format_content
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

    def is_unchange
      operation == UNCHANGE
    end

    def s_line_number
      source_line.line
    end

    def t_line_number
      target_line.line
    end

    def format_user
      if operation == DiffLine::DELETE
        return source_line.user
      elsif operation == DiffLine::ADD
        return target_line.user
      else
        return source_line.user
      end
    end
  end
end
