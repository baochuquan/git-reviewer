require 'digest'

class BlameBranch
    attr_accessor :branch 
    attr_accessor :blameFiles

    def initialize(branch, blameFiles)
        @branch = branch
        @blameFiles = blameFiles
    end
end

class BlameFile
    VALID = 0
    BINARY = 1
    NOTEXIST = 2

    attr_accessor :filename
    attr_accessor :blameLines
    attr_accessor :property         # 属性，VALID/BINARY/NOTEXIST

    def initialize(filename, blameLines, property)
        @filename = filename
        @blameLines = blameLines
        @property = property
    end
end

class BlameLine
    attr_accessor :hash
    attr_accessor :user
    attr_accessor :date
    attr_accessor :line
    attr_accessor :code
    attr_accessor :description

    def initialize(hash, user, date, line, code)
        @hash = hash
        @user = user
        @date = date
        @line = line
        @code = code
        @description = code
    end

    # def uuid 
    #     # 不包含行号
    #     string = hash + user + date + code 
    #     return Digest::MD5.hexdigest(string)
    # end

    # 用于 Myers 中进行判等操作
    def ==(other) 
        other.is_a?(BlameLine) && other.code == @code 
    end
end
