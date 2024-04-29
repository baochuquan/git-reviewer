module GitReviewer
  class Checker
    # 判断当前是否在一个 Git 仓库中
    def self.is_git_repository_exist?
      cmd = "git rev-parse --is-inside-work-tree > /dev/null 2>&1"
      success = system(cmd)
      return success
    end

    # 判断 Git 分支是否存在
    def self.is_git_branch_exist?(branch)
      cmd = "git show-ref --verify --quiet refs/heads/#{branch}"
      success = system(cmd)
      return success
    end

    # 判断 {指定分支，指定文件} 是否存在
    def self.is_file_exist?(branch, filename)
      cmd = "git ls-tree -r #{branch} --name-only | grep '#{filename}' > /dev/null 2>&1"
      success = system(cmd)
      return success
    end

    # 判断一个文件是否为二进制文件
    def self.is_file_binary?(branch, filename)
      tmpfile = "/tmp/analyzer-tmp-file"
      cmd = "git show #{branch}:#{filename.chomp} > #{tmpfile}"
      `#{cmd}`

      cmd = "file --mime #{tmpfile}"
      result = `#{cmd}`

      cmd = "rm #{tmpfile}"
      `#{cmd}`
      return result.include? 'charset=binary'
    end

    # 分析「指定分支、指定文件」的快照信息
    def self.snapshot_of_blame_file(branch, filename)
      cmd = "git blame #{branch} -l -c #{filename}"
      result = `#{cmd}`
      return result
    end

    # 分析两个分支之间修改的文件
    def self.diff_files(source, target)
      cmd = "git merge-base #{source} #{target}"
      merge_base = `#{cmd}`
      merge_base = merge_base.chomp

      cmd = "git diff --name-only #{merge_base} #{source}"
      result = `#{cmd}`
      result = result.lines.map { |line| line.chomp }
      return result
    end

    def self.current_git_branch
      cmd = "git symbolic-ref --short HEAD"
      result = `#{cmd}`
      return result.chomp
    end
  end
end
