require 'open3'
require_relative 'blame-tree'

class BlameAnalyzer
    attr_accessor :sourceBranch       # source branch
    attr_accessor :targetBranch
    attr_accessor :sourceBlame 
    attr_accessor :targetBlame

    def initialize(sourceBranch, targetBranch)
        @sourceBranch = sourceBranch
        @targetBranch = targetBranch
    end

    # 判断指定分支，指定文件是否存在
    def checkFileExist(branch, filename) 
        cmd = "git ls-tree -r #{branch} --name-only | grep '#{filename}' > /dev/null 2>&1"
        success = system(cmd)
        return success
    end

    def checkFileBinary(branch, filename)
        tmpfile = "/tmp/analyzer-tmp-file"
        cmd = "git show #{branch}:#{filename} > #{tmpfile}"
        `#{cmd}`

        cmd = "file --mime #{tmpfile}"
        result = `#{cmd}`

        cmd = "rm #{tmpfile}"
        `#{cmd}`
        return result.include? 'charset=binary'
    end

    # 判断分支是否存在
    def checkBranch(branch)
        cmd = "git show-ref --verify --quiet refs/heads/#{branch}"
        success = system(cmd)
        return success
    end

    # 判断当前是否在一个 git 仓库中
    def checkRepository?
        cmd = "git rev-parse --is-inside-work-tree > /dev/null 2>&1"
        success = system(cmd)
        return success
    end

    # 分析指定分支、指定文件的快照信息
    def fileSnapshotBlameContent(branch, filename) 
        cmd = "git blame #{branch} -l -c #{filename}"
        result = `#{cmd}`
        return result
    end

    # 分析两个分支之间修改的文件
    def diffFiles
        cmd = "git diff --name-only #{@targetBranch} #{@sourceBranch}"
        result = `#{cmd}`
        return result.lines
    end

    def blameBranch(branch, files)
        blameFiles = []
        puts files 
        puts "\n"
        files.each do |file|
            puts file 
            if checkFileExist(branch, file) then
                if checkFileBinary(branch, file) 
                    puts "exist binary, #{branch}"
                    # TODO: @baocq 二进制
                    blameFiles.append(BlameFile.new(file, []))
                else 
                    puts "exist code, #{branch}"
                    blameFiles.append(blameFile(branch, file))
                end
            else
                puts "not exist, #{branch}"
                blameFiles.append(BlameFile.new(file, []))
            end
        end
        result = BlameBranch.new(branch, blameFiles)
        return result
    end

    def blameFile(branch, filename)
        blameLines = []
        content = fileSnapshotBlameContent(branch, filename)
        # 遍历文件的每一行，得到 BlameLine 数组
        content.lines do |line|
            blameLines.append(blameLine(line)) 
        end

        result = BlameFile.new(filename, blameLines)
        return result
    end

    def blameLine(text)
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
        # puts "UUID: #{result.uuid}"
        # puts "Hash: #{result.hash}"
        # puts "User: #{result.user}"
        # puts "Date: #{result.date}"
        # puts "Line: #{result.line}"
        # puts "Code: #{result.code}"
        # puts "--------------------------------------------------------------------------------------------------------------"
        return result
    end

    def analyzeSummary
        if !checkRepository? 
            # TODO: 打印内容，退出程序
            raise "The command execution environment must be a git repository."
        end

        if !checkBranch(@targetBranch)
            raise "The target branch does not exist in the current git repository."
        end

        # 遍历分支改动的每个文件，得到 BlameFile 数组
        files = diffFiles
        if files == nil or files.count == 0
            raise "TODO"
        end

        @sourceBlame = blameBranch(@sourceBranch, files)
        @targetBlame = blameBranch(@targetBranch, files)
        
        if @sourceBlame.blameFiles.count != @targetBlame.blameFiles.count 
            raise "xxxx"
        end

        reviewer = {}
        @sourceBlame.blameFiles.each_with_index do |sfile, index|
            tfile = @targetBlame.blameFiles[index]
            if tfile != nil && tfile.blameLines != nil && tfile.blameLines.count == 0 then
                reviewer["new"] = 0 unless hash.key?("new")
                reviewer["new"] += 1
            else
                puts ""
            end
        end
    end
end


#  fileSnapshot("Podfile", "")
# blameLine("fccef8a7c	(     baocq	2021-03-15 18:19:15 +0800	233)  end")
# blameLine("c89d22a6a	( weihuilin	2023-02-08 11:48:18 +0800	31)            let view = CardPopupDetailView(scene: scene, isAnimation: true)")
# blameLine("cc3e11c47 (baocq       2021-11-15 06:44:52 +0000 100)   pod 'YTKUtils', '~> 1.3'")
