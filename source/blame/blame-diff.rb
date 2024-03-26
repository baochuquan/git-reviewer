require_relative 'blame-tree'

class BlameFileDiff
    DELETE = 1      # 删除文件
    ADD = 2         # 新增文件
    MODIFY = 3      # 修改文件

    attr_accessor :operation
    attr_accessor :filename
    attr_accessor :diffLines

    def initialize(filename, diffLines, operation)
        @filename = filename
        @diffLines = diffLines
        @operation = operation
    end
end

class BlameLineDiff
    DELETE = 1      # 删除行
    ADD = 2         # 新增行

    attr_accessor :line 
    attr_accessor :operation

    def initialize(line, operation)
        @line = line
        @operation = operation
    end
end