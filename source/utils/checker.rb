
class Checker 
    # 判断当前是否在一个 Git 仓库中
    def self.isGitRepositoryExist?
        cmd = "git rev-parse --is-inside-work-tree > /dev/null 2>&1"
        success = system(cmd)
        return success
    end

    # 判断 Git 分支是否存在
    def self.isGitBranchExist?(branch)
        cmd = "git show-ref --verify --quiet refs/heads/#{branch}"
        success = system(cmd)
        return success
    end

    # 判断 {指定分支，指定文件} 是否存在
    def self.isFileExist?(branch, filename) 
        cmd = "git ls-tree -r #{branch} --name-only | grep '#{filename}' > /dev/null 2>&1"
        success = system(cmd)
        return success
    end

    # 判断一个文件是否为二进制文件
    def self.isFileBinary?(branch, filename)
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
    def self.snapshotOfBlameFile(branch, filename) 
        cmd = "git blame #{branch} -l -c #{filename}"
        result = `#{cmd}`
        return result
    end

    # 分析两个分支之间修改的文件
    def self.diffFiles(source, target)
        cmd = "git diff --name-only #{source} #{target}"
        result = `#{cmd}`
        result = result.lines.map { |line| line.chomp }
        # Printer.put result
        return result
    end

end