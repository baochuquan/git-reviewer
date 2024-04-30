require 'digest'

module GitReviewer
  # BlameBranch
  class BlameBranch
    attr_accessor :branch
    attr_accessor :blame_files

    def initialize(branch, blame_files)
      @branch = branch
      @blame_files = blame_files
    end
  end

  # BlameFile
  class BlameFile
    attr_accessor :file_name
    attr_accessor :blame_lines

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

    def initialize(file_name, blame_lines, exist, binary)
      @file_name = file_name
      @blame_lines = blame_lines
      @exist = exist
      @binary = binary
    end
  end

  # BlameLine
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

    # 用于 Myers 中进行判等操作
    def ==(other)
      other.is_a?(BlameLine) && other.code == @code
    end

    def format_line
      format('%5d', line)
    end

    def format_user
      user.rjust(16)
    end
  end
end
