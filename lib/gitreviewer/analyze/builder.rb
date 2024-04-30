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
      # 遍历分支改动的每个文件，得到 BlameFile 数组
      files = Checker.diff_files(@source_branch, @target_branch)
      header_length = 0

      if files == nil || files.count == 0
        Printer.warning "Warning: there are no analyzable differences between the target branch and source branch."
        exit 0
      else
        header = "============ Diff files between source<#{@source_branch}> and target<#{@target_branch}> ============"
        header_length = header.length
        footer = "=" * header_length

        Printer.verbose_put header
        Printer.verbose_put files
        Printer.verbose_put footer
        Printer.verbose_put "\n"
      end

      # 构建 source branch 的 BlameBranch
      source_header_title = " Source Blame Files "
      target_header_title = " Target Blame Files "
      source_prefix_length = (header_length - source_header_title.length) / 2
      target_prefix_length = (header_length - target_header_title.length) / 2
      source_header = "=" * source_prefix_length + source_header_title + "=" * (header_length - source_prefix_length - source_header_title.length)
      target_header = "=" * target_prefix_length + target_header_title + "=" * (header_length - target_prefix_length - target_header_title.length)
      footer = "=" * header_length

      # 打印 source branch Log
      Printer.verbose_put source_header
      files.each do |file_name|
        Printer.verbose_put "#{file_name}"
      end
      Printer.verbose_put footer
      Printer.verbose_put "\n"

      # 打印 target branch Log
      Printer.verbose_put target_header
      files.each do |file_name|
        Printer.verbose_put "#{file_name}"
      end
      Printer.verbose_put footer
      Printer.verbose_put "\n"

      # 构建 source branch & target branch
      @source_blame = blame_branch(@source_branch, files)
      @target_blame = blame_branch(@target_branch, files)

      # 构建 diff_files
      @diff_files = []
      @source_blame.blame_files.each_with_index do |sfile, index|
        tfile = @target_blame.blame_files[index]
        # Diff 时需要交换 tfile 和 sfile
        myers = Myers.new(tfile, sfile)
        @diff_files.append(myers.resolve)
      end

      # 打印 Code Diff

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
      return result
    end
  end
end
