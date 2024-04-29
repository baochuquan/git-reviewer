require 'digest'

module GitReviewer
  class BlameBranch
    attr_accessor :branch
    attr_accessor :blameFiles

    def initialize(branch, blameFiles)
      @branch = branch
      @blameFiles = blameFiles
    end
  end

  class BlameFile
    attr_accessor :filename
    attr_accessor :blameLines

    attr_writer :exist
    attr_writer :binary

    # 文件是否存在
    def exist?
      @exist
    end

    # 文件是否是二进制
    def binary?
      @binary
    end

    def initialize(filename, blameLines, exist, binary)
      @filename = filename
      @blameLines = blameLines
      @exist = exist
      @binary = binary
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

    def formatLine
      format('%5d', line)
    end

    def formatUser
      user.rjust(16)
    end
  end
end
