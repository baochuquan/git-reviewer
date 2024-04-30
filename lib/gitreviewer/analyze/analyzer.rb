require 'open3'
require_relative 'blame_tree'
require_relative 'builder'
require_relative '../utils/printer'
require_relative '../utils/checker'
require_relative '../config/configuration'
require_relative 'result_item'

module GitReviewer


  class Analyzer
    attr_accessor :source_branch        # source branch
    attr_accessor :target_branch        # target branch
    attr_accessor :builder              # blame builder

    attr_accessor :author_results       #
    attr_accessor :reviewer_results     #
    attr_accessor :configuration        # 配置信息 Configuration

    def initialize(source_branch, target_branch)
      @source_branch = source_branch
      @target_branch = target_branch
      @author_results = Hash.new
      @reviewer_results = Hash.new
    end


    def setup_builder
      # 构建 BlameTree
      @builder = Builder.new(@source_branch, @target_branch)
      @builder.build

      if @builder.source_blame.blame_files.count == 0
        raise "blameFiles of sourceBlameBranch is zero"
      end

      if @builder.target_blame.blame_files.count == 0
        raise "blameFiles of targetBlameBranch is zero"
      end

      if @builder.source_blame.blame_files.count != @builder.target_blame.blame_files.count
        raise "xxxx"
      end

      if @builder.diff_files == nil
        raise "diffs of builder is nil"
      end
    end

    def setup_configuration
      file_name = ".gitreviewer.json"
      file_exist = File.exist?(file_name)
      # 检测配置文件
      if !file_exist
        Printer.red "Error: `.gitreviewer.json` not exist in current directory."
        exit 1
      end
      # 解析配置文件
      file_content = File.read(file_name)
      data = JSON.parse(file_content)
      @configuration = Configuration.new(data['project_owner'], data['folder_owner'], data['file_owner'], data['ignore_reviewer_folders'], data['ignore_reviewer_files'])
    end

    def execute
      setup_builder
      setup_configuration
      analyze_author
      analyze_reviewer

    #   print_author_result
    #   print "\n"
    #   print_reviewer_result
    #   print "\n"
    end

    def analyze_author
      @builder.diff_files.each do |fdiff|
        fdiff.diff_lines.each_with_index do |ldiff, index|
        record_author(fdiff, ldiff)
        end
      end
    end

    def analyze_reviewer
      @builder.diff_files.each do |fdiff|
        reviewer = nil
        lines = 0

        # 其他操作按行计算权重
        fdiff.diff_lines.each_with_index do |ldiff, index|
          if ldiff.operation == DiffLine::DELETE
            # 删除行: 由原作者 review
            reviewer = ldiff.source_line.user
            record_reviewer(fdiff, reviewer, 1)
          elsif ldiff.operation == DiffLine::ADD
            # 新增行
            if reviewer != nil
              # 紧随删除，由删除行的原作者 review
              lines += 1
            else
              # 非紧随删除，由 configuration 决定谁来 review
              reviewer = @configuration.reviewer_of_file(fdiff.file_name)
            record_reviewer(fdiff, reviewer, 1)
            end
          else
            # 未变化
            if reviewer != nil
              # 处理编辑类型
              record_reviewer(fdiff, reviewer, lines)
              reviewer = nil
              lines = 0
            end
          end

          # 最后一行
          if index == fdiff.diff_lines.count - 1 && reviewer != nil
            record_reviewer(fdiff, reviewer, lines)
          end
        end
      end
    end

    def record_author(fdiff, ldiff)
      author = ""
      if ldiff.operation == DiffLine::DELETE
        author = ldiff.source_line.user
      else
        author = ldiff.target_line.user
      end

      item = @author_results[author]
      if item == nil
        item = ResultItem.new(author)
      end
      item.add_file_name(fdiff.file_name)
      item.add_line_count(1)
      @author_results[author] = item
    end

    def record_reviewer(fdiff, reviewer, lines)
      if reviewer == nil
        return
      end
      item = @reviewer_results[reviewer]
      if item == nil
        item = ResultItem.new(reviewer)
      end
      item.add_file_name(fdiff.file_name)
      item.add_line_count(lines)
      @reviewer_results[reviewer] = item
    end

    def print_author_result
      print @author_results
    end

    def print_reviewer_result
      print @reviewer_results
    end
  end
end
