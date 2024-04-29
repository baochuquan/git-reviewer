require_relative 'blame_tree'

module GitReviewer

  class BlameFileDiff
    UNKNOWN = 0     # 未知情况，理论上不存在
    DELETE = 1      # 删除文件
    ADD = 2         # 新增文件
    MODIFY = 3      # 修改文件

    attr_accessor :operation
    attr_accessor :filename
    attr_accessor :diffLines    #BlameLineDiff

    attr_writer :binary

    def binary?
      @binary
    end

    def initialize(filename, diffLines, operation, binary)
      @filename = filename
      @diffLines = diffLines
      @operation = operation
      @binary = binary
    end

    def format_property
      result = ""
      case @operation
      when BlameFileDiff::UNKNOWN
        result += "operation<UNKNOWN>"
      when BlameFileDiff::DELETE
        result += "operation<DELETE>"
      when BlameFileDiff::ADD
        result += "operation<ADD>"
      when BlameFileDiff::MODIFY
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
       return "filename<#{filename}>"
    end

    def format_line_diff
      result = ""
      diffLines.each do |line|
        if line.operation == BlameLineDiff::DELETE
          result += "\033[0;31m#{line.sLine.format_user} #{line.sLine.format_line} - #{line.sLine.description}\033[0m\n"
        elsif line.operation == BlameLineDiff::ADD
          result += "\033[0;32m#{line.tLine.format_user} #{line.tLine.format_line} + #{line.tLine.description}\033[0m\n"
        else
          # TODO: @baocq
          # result += "#{line.tLine.format_user} #{line.tLine.format_line}   #{line.tLine.description}\n"
        end
      end
      return result
    end
  end

  class BlameLineDiff
    UNCHANGE = 0    # 未变化
    DELETE = 1      # 删除行
    ADD = 2         # 新增行

    # 对于 UNCHANGE 操作，sLine 有值，tLine 有值
    # 对于 DELETE 操作，sLine 有值，tLine 无值
    # 对于 ADD 操作，sLine 无值，tLine 有值

    attr_accessor :sLine        # 原始行, BlameLine
    attr_accessor :tLine        # 目标行, BlameLine
    attr_accessor :operation

    def initialize(sLine, tLine, operation)
      @sLine = sLine
      @tLine = tLine
      @operation = operation
    end

    def s_line_number
      sLine.line
    end

    def t_line_number
      tLine.line
    end
  end
end
