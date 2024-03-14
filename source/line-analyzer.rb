#!/usr/bin/ruby 

require 'open3'
require 'digest'


class BlameBranch
    attr_accessor :branch 
    attr_accessor :blameFiles

    def initialize(filename, blameFiles)
        @filename = filename
        @blameFiles = blameFiles
    end
end

class BlameFile
    attr_accessor :filename
    attr_accessor :blameLines

    def initialize(filename, blamelines)
        @filename = filename
        @blameLines = blameLine
    end
end

class BlameLine
    attr_accessor :hash
    attr_accessor :user
    attr_accessor :date
    attr_accessor :line
    attr_accessor :code

    def initialize(hash, user, date, line, code)
        @hash = hash
        @user = user
        @date = date
        @line = line
        @code = code
    end

    def uuid 
        # 不包含行号
        string = hash + user + date + code 
        return Digest::MD5.hexdigest(string)
    end
end

# 判断指定分支，指定文件是否存在
def checkFile(branch, filename) 
    cmd = "git ls-tree -r #{branch} --name-only | grep '#{filename}' > /dev/null 2>&1"
    success = system(cmd)
    return success
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
 def fileSnapshotBlameContent(filename, branch) 
    cmd = "git blame #{branch} -l -c #{filename}"
    result = `#{cmd}`
    return result
 end

 # 分析两个分支之间修改的文件
def diffFiles(targetBranch, sourceBranch)
    cmd = "git diff --name-only #{targetBranch} #{sourceBranch}"
    result = `#{cmd}`
    return result.lines
end

def blameBranch(branch)
    blameFiles = []
    # 遍历分支改动的每个文件，得到 BlameFile 数组
    files = diffFiles(branch, "HEAD")
    files.lines do |file|
        if checkFile(branch, file) then
            blameFiles.append(blameFile(file, branch))
        else
            blameFiles.append(BlameFile.new(filename, []))
        end
    end
    result = BlameBranch.new(branch, blameFiles)
    return result
end

def blameFile(filename, branch)
    blameLines = []
    content = fileSnapshotBlameContent(filename, branch)
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

def analyzeSummary(targetBranch)
    if !checkRepository? 
        # TODO: 打印内容，退出程序
        raise "The command execution environment must be a git repository."
    end

    if !checkBranch(targetBranch)
        raise "The target branch does not exist in the current git repository."
    end

    currentBlameBranch = blameBranch("HEAD")
    targetBlameBranch = blameBranch(targetBranch)
    
    if currentBlameBranch.blameFiles.count != targetBlameBranch.blameFiles.count 
        raise "xxxx"
    end

    reviewer = {}
    currentBlameBranch.blameFiles.each_with_index do |cfile, index|
        tfile = targetBlameBranch.blameFiles[index]
        if tfile.blameLines.count == 0 then
            reviewer["new"] = 0 unless hash.key?("new")
            reviewer["new"] += 1
        else

        end
    end
end

#  fileSnapshot("Podfile", "")
# blameLine("fccef8a7c	(     baocq	2021-03-15 18:19:15 +0800	233)  end")
# blameLine("c89d22a6a	( weihuilin	2023-02-08 11:48:18 +0800	31)            let view = CardPopupDetailView(scene: scene, isAnimation: true)")
# blameLine("cc3e11c47 (baocq       2021-11-15 06:44:52 +0000 100)   pod 'YTKUtils', '~> 1.3'")


analyzeSummary("master")