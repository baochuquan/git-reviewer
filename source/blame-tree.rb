require 'digest'

class BlameBranch
    attr_accessor :branch 
    attr_accessor :blameFiles

    def initialize(filename, blameFiles)
        @filename = filename
        @blameFiles = blameFiles
    end
end

class BlameFile
    attr_accessor :filename
    attr_accessor :blameLines

    def initialize(filename, blamelines)
        @filename = filename
        @blameLines = blameLines
    end
end

class BlameLine
    attr_accessor :hash
    attr_accessor :user
    attr_accessor :date
    attr_accessor :line
    attr_accessor :code

    def initialize(hash, user, date, line, code)
        @hash = hash
        @user = user
        @date = date
        @line = line
        @code = code
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
