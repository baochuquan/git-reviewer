require 'open3'
require_relative '../blame/blame-tree'
require_relative '../blame/blame-builder'
require_relative 'printer'
require_relative 'checker'
require_relative 'reviewer'

class Analyzer
    attr_accessor :sourceBranch       # source branch
    attr_accessor :targetBranch
    attr_accessor :builder 

    attr_accessor :reviewers

    def initialize(sourceBranch, targetBranch)
        @sourceBranch = sourceBranch
        @targetBranch = targetBranch
    end


    def setupBuilder
        # 构建 BlameTree
        @builder = BlameBuilder.new(@sourceBranch, @targetBranch)
        @builder.build

        if @builder.sourceBlame.blameFiles.count == 0 
            raise "blameFiles of sourceBlameBranch is zero"
        end

        if @builder.targetBlame.blameFiles.count == 0 
            raise "blameFiles of targetBlameBranch is zero"
        end

        if @builder.sourceBlame.blameFiles.count != @builder.targetBlame.blameFiles.count 
            raise "xxxx"
        end

        if @builder.diffs == nil 
            raise "diffs of builder is nil"
        end
    end

    def summary
        setupBuilder
    end

    def setupReviewers
        setupBuilder

        @reviewers = Hash.new

        @builder.diffs.each do |fdiff|
            editor = nil 
            score = 0
            
            # 其他操作按行计算权重
            fdiff.diffLines.each_with_index do |ldiff, index|
                if ldiff.operation == BlameLineDiff::DELETE
                    # 删除行
                    editor = ldiff.sLine.user
                    record(editor, 1)
                elsif ldiff.operation == BlameLineDiff::ADD
                    # 新增行
                    if editor != nil 
                        # 紧随删除，积分
                        score += 1
                    else 
                        # 非紧随删除
                        record(ldiff.tLine.user, 1)
                    end
                else 
                    # 未变化
                    if editor != nil 
                        # 处理编辑类型
                        record(editor, score)
                        editor = nil 
                        score = 0
                    end 
                end
                # 最后一行
                if index == fdiff.diffLines.count - 1 && editor != nil 
                    record(editor, score)
                end
            end
        end 
    end

    def makeDecision
        Printer.put "\n"
        Printer.yellow "============ Reviewers ============"
        @reviewers.each do |key, value|
            Printer.put key 
            Printer.put "  -> #{value.score}"
        end
    end

    def record(username, score)
        rv = @reviewers[username]
        if rv == nil 
            @reviewers[username] = Reviewer.new(username, score)
            return 
        end

        rv.score += score 
        @reviewers[username] = rv
    end
end