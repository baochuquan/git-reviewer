require 'open3'
require_relative 'blame_tree'
require_relative '../utils/printer'
require_relative '../utils/checker'
require_relative '../algorithm/myers'

module GitReviewer
  class BlameBuilder
    attr_accessor :sourceBranch         # source branch
    attr_accessor :targetBranch
    attr_accessor :sourceBlame          # BlameBranch
    attr_accessor :targetBlame          # BlameBranch

    attr_accessor :diffs                # Array<BlameFileDiff>

    def initialize(sourceBranch, targetBranch)
      @sourceBranch = sourceBranch
      @targetBranch = targetBranch
    end

    def build
      # 检查环境
      check_environment
      # 遍历分支改动的每个文件，得到 BlameFile 数组
      files = Checker.diff_files(@sourceBranch, @targetBranch)
      if files == nil or files.count == 0
        raise "TODO"
      else
        Printer.yellow "============ Diff files between source<#{@sourceBranch}> and target<#{@targetBranch}> ============"
        Printer.put files
        Printer.put "\n"
      end

      # 构建 source branch 的 BlameBranch
      Printer.yellow "============ source BlameFiles ============"
      @sourceBlame = blame_branch(@sourceBranch, files)
      Printer.put "\n"

      # 构建 target branch 的 BlameBranch
      Printer.yellow "============ target BlameFiles ============"
      @targetBlame = blame_branch(@targetBranch, files)
      Printer.put "\n"

      # 构建 diffs
      @diffs = []
      @sourceBlame.blameFiles.each_with_index do |sfile, index|
        tfile = @targetBlame.blameFiles[index]
        # Diff 时需要交换 tfile 和 sfile
        myers = Myers.new(tfile, sfile)
         @diffs.append(myers.resolve)
      end
    end

    def check_environment
      # 检查当前是否是 Git 仓库
      if !Checker.is_git_repository_exist?
        raise "The command execution environment must be a git repository."
      end

      # 检查原始分支是否存在
      if !Checker.is_git_branch_exist?(@sourceBranch)
        raise "The source branch does not exist in the current git repository."
      end

      # 检查目标分支是否存在
      if !Checker.is_git_branch_exist?(@targetBranch)
        raise "The target branch does not exist in the current git repository."
      end
    end

    def blame_branch(branch, files)
      blameFiles = []
      files.each do |filename|
        bf = BlameFile.new("", [], false, false)

        if Checker.is_file_exist?(branch, filename) then
          if Checker.is_file_binary?(branch, filename)
            bf = BlameFile.new(filename, [], true, true)
          else
            bf = blame_file(branch, filename)
          end
        else
          bf = BlameFile.new(filename, [], false, false)
        end
        blameFiles.append(bf)
        Printer.put "BlameFile -> #{bf.filename}"
      end
      result = BlameBranch.new(branch, blameFiles)
      return result
    end

    def blame_file(branch, filename)
      blameLines = []
      content = Checker.snapshot_of_blame_file(branch, filename)
      # 遍历文件的每一行，得到 BlameLine 数组
      content.lines do |line|
        blameLines.append(blame_line(line))
      end

      result = BlameFile.new(filename, blameLines, true, false)
      return result
    end

    def blame_line(text)
      # 获取哈希值
      hash = text.slice!(0, 40)
      rest = text.strip
      # 移除 (
      rest = rest[1..-1]
      # 根据时间格式进行拆分
      pattern = /\b\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [+-]\d{4}\b/
      pattern_index = rest.index(pattern)
      pattern_index = pattern_index + 25      # 2022-04-08 06:19:37 -0200 长度为 25
      # 根据特定位置进行拆分
      user_date = rest.slice(0, pattern_index)
      rest = rest.slice(pattern_index , rest.length)
      # user_date, rest = rest.split("+", 2)
      user_date = user_date.strip
      # 提取作者，日期。日期：提取倒数 19 个字符
      date = user_date.slice!(-25, 25)
      date = date.strip
      user = user_date.strip
      # # 提取行号，代码
      line, code = rest.split(")", 2)
      line = line.strip
      # 结果
      result = BlameLine.new(hash, user, date, line, code)
      # Printer.put "UUID: #{result.uuid}"
      # Printer.put "Hash: #{result.hash}"
      # Printer.put "User: #{result.user}"
      # Printer.put "Date: #{result.date}"
      # Printer.put "Line: #{result.line}"
      # Printer.put "Code: #{result.code}"
      # Printer.put "--------------------------------------------------------------------------------------------------------------"
      return result
    end
  end
end
