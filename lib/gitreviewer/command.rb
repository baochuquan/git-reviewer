require 'claide'
require_relative './analyze/blame_tree'
require_relative './analyze/builder'
require_relative './analyze/analyzer'
require_relative './algorithm/myers'
require_relative './option/init_option'
require_relative './utils/checker'
require_relative './option/analyze_option'

module GitReviewer

  class Command < CLAide::Command

    self.abstract_command = false

    self.description = <<-DESC
      git-reviewer is a git plugin used to analyze who should review a Merge Request or Pull Request, and more details related to code modifications.
    DESC

    self.command = 'git-reviewer'

    def self.options
      [
        ['--init', 'Initialize the code review configuration file of the Git repository. It will generate a `gitreviewer.json` file if needed.'],
        ['--target', 'The target branch to be analyzed, which is the same as the target branch selected when creating a Merge Request or Pull Request.'],
        ['--source', 'Optional, if not specified, the default is the current branch pointed to by Git HEAD. The source branch to be analyzed, which is the same as the source branch selected when creating a Merge Request or Pull Request. '],
        ['--author', 'Only analyze relevant authors involved in code changes.'],
        ['--reviewer', 'Only analyze suggested reviewers for code changes.'],
    ].concat(super)
    end

    def initialize(argv)
      @init = argv.flag?('init', false)
      @target = argv.option('target')
      @source = argv.option('source')
      @analyze_reviewer = argv.flag?('reviewer', false)
      @analyze_author = argv.flag?('author', false)
      super
    end

    def run
      # 处理 help 选项
      if @help_arg
        help!
        return
      end

      # 处理 version 选项
      if @version
        puts "git-reviewer #{GitReviewer::VERSION}"
        return
      end

      # 处理 init 选项
      if @init
        initOption = InitOption.new
        initOption.execute
        return
      end

      # 分析
      analyze
    end

    def analyze
      # 检查环境
      if !Checker.is_git_repository_exist?
        Printer.red "Error: git repository not exist. Please execute the command in the root director of a git repository."
        exit 1
      end
      # 检查参数
      if !@analyze_author && !@analyze_reviewer
        # 如果两个选项均没有，则默认分析作者和审查者
        @analyze_author = true
        @analyze_reviewer = true
      end
      # 设置默认分支
      if @source == nil
        # 默认 source 为当前分支
        @source = Checker.current_git_branch
      end
      if @target == nil
        Printer.red "Error: target branch cannot be nil or empty. Please use `--target=<branch>` to specify the target branch."
        exit 1
      end

      # 检查分支
      if @source != nil && @target != nil
        # source 分支
        if !Checker.is_git_branch_exist?(@source)
          Printer.red "Error: source branch `#{@source}` not exist."
          exit 1
        end
        # target 分支
        if !Checker.is_git_branch_exist?(@target)
          Printer.red "Error: target branch `#{@target}` not exist."
          exit 1
        end
        # source、target 判重
        if @source == @target
          Printer.red "Error: source branch and target branch should not be the same."
          exit 1
        end
      end

      # 执行分析
      analyzeOption = AnalyzeOption.new(@source, @target, @analyze_author, @analyze_reviewer, @verbose)
      analyzeOption.execute
    end
  end
end
