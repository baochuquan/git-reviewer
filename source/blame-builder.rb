require 'open3'
require_relative 'blame-tree'
require_relative 'utils/printer'
require_relative 'utils/checker'

class BlameBuilder
    attr_accessor :sourceBranch       # source branch
    attr_accessor :targetBranch
    attr_accessor :sourceBlame        # BlameBranch
    attr_accessor :targetBlame        # BlameBranch

    def initialize(sourceBranch, targetBranch)
        @sourceBranch = sourceBranch
        @targetBranch = targetBranch
    end

    def build
        # 检查环境
        checkEnvironment
        # 遍历分支改动的每个文件，得到 BlameFile 数组
        files = Checker.diffFiles(@sourceBranch, @targetBranch)
        if files == nil or files.count == 0
            raise "TODO"
        end

        Printer.yellow "============ Diff files between source<#{@sourceBranch}> and target<#{@targetBranch}> ============"
        Printer.put files
        Printer.put "\n"

        Printer.yellow "============ source BlameFiles ============"
        @sourceBlame = blameBranch(@sourceBranch, files)
        Printer.put "\n"

        Printer.yellow "============ target BlameFiles ============"
        @targetBlame = blameBranch(@targetBranch, files)
        Printer.put "\n"
    end

    def checkEnvironment
        # 检查当前是否是 Git 仓库
        if !Checker.isGitRepositoryExist? 
            # TODO: 打印内容，退出程序
            raise "The command execution environment must be a git repository."
        end

        # 检查原始分支是否存在
        if !Checker.isGitBranchExist?(@sourceBranch)
            raise "The source branch does not exist in the current git repository."
        end

        # 检查目标分支是否存在
        if !Checker.isGitBranchExist?(@targetBranch)
            raise "The target branch does not exist in the current git repository."
        end
    end

    def blameBranch(branch, files)
        blameFiles = []
        files.each do |file|
            if Checker.isFileExist?(branch, file) then
                if Checker.isFileBinary?(branch, file) 
                    # TODO: @baocq 二进制
                    blameFiles.append(BlameFile.new(file, []))
                else 
                    blameFiles.append(blameFile(branch, file))
                end
            else
                blameFiles.append(BlameFile.new(file, []))
            end
        end
        result = BlameBranch.new(branch, blameFiles)
        return result
    end

    def blameFile(branch, filename)
        blameLines = []
        content = Checker.snapshotOfBlameFile(branch, filename)
        # 遍历文件的每一行，得到 BlameLine 数组
        content.lines do |line|
            blameLines.append(blameLine(line)) 
        end

        Printer.put "blameFile -> #{filename}"
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