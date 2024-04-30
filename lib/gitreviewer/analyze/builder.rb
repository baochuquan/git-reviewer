require 'open3'
require_relative 'blame_tree'
require_relative '../utils/printer'
require_relative '../utils/checker'
require_relative '../algorithm/myers'

module GitReviewer
  class Builder
    attr_accessor :source_branch         # source branch
    attr_accessor :target_branch
    attr_accessor :source_blame          # BlameBranch
    attr_accessor :target_blame          # BlameBranch

    attr_accessor :diff_files                # Array<DiffFiles>

    def initialize(source_branch, target_branch)
      @source_branch = source_branch
      @target_branch = target_branch
    end

    def build
      # 检查环境
      check_environment
      # 遍历分支改动的每个文件，得到 BlameFile 数组
      files = Checker.diff_files(@source_branch, @target_branch)
      if files == nil or files.count == 0
        Printer.red ""
      else
        Printer.yellow "============ Diff files between source<#{@source_branch}> and target<#{@target_branch}> ============"
        Printer.put files
        Printer.put "\n"
      end

      # 构建 source branch 的 BlameBranch
      Printer.yellow "============ source BlameFiles ============"
      @source_blame = blame_branch(@source_branch, files)
      Printer.put "\n"

      # 构建 target branch 的 BlameBranch
      Printer.yellow "============ target BlameFiles ============"
      @target_blame = blame_branch(@target_branch, files)
      Printer.put "\n"

      # 构建 diff_files
      @diff_files = []
      @source_blame.blame_files.each_with_index do |sfile, index|
        tfile = @target_blame.blame_files[index]
        # Diff 时需要交换 tfile 和 sfile
        myers = Myers.new(tfile, sfile)
         @diff_files.append(myers.resolve)
      end
    end

    def check_environment
      # 检查当前是否是 Git 仓库
      if !Checker.is_git_repository_exist?
        raise "The command execution environment must be a git repository."
      end

      # 检查原始分支是否存在
      if !Checker.is_git_branch_exist?(@source_branch)
        raise "The source branch does not exist in the current git repository."
      end

      # 检查目标分支是否存在
      if !Checker.is_git_branch_exist?(@target_branch)
        raise "The target branch does not exist in the current git repository."
      end
    end

    def blame_branch(branch, files)
      blame_files = []
      files.each do |file_name|
        bf = BlameFile.new("", [], false, false)

        if Checker.is_file_exist?(branch, file_name) then
          if Checker.is_file_binary?(branch, file_name)
            bf = BlameFile.new(file_name, [], true, true)
          else
            bf = blame_file(branch, file_name)
          end
        else
          bf = BlameFile.new(file_name, [], false, false)
        end
        blame_files.append(bf)
        Printer.put "BlameFile -> #{bf.file_name}"
      end
      result = BlameBranch.new(branch, blame_files)
      return result
    end

    def blame_file(branch, file_name)
      blame_lines = []
      content = Checker.snapshot_of_blame_file(branch, file_name)
      # 遍历文件的每一行，得到 BlameLine 数组
      content.lines do |line|
        blame_lines.append(blame_line(line))
      end

      result = BlameFile.new(file_name, blame_lines, true, false)
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
