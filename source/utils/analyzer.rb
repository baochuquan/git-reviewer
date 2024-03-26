require 'open3'
require_relative '../blame/blame-tree'
require_relative '../blame/blame-builder'
require_relative 'printer'
require_relative 'checker'

class Analyzer
    attr_accessor :sourceBranch       # source branch
    attr_accessor :targetBranch
    attr_accessor :builder 

    def initialize(sourceBranch, targetBranch)
        @sourceBranch = sourceBranch
        @targetBranch = targetBranch
    end

    def summary
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

        reviewer = {}
       @builder.sourceBlame.blameFiles.each_with_index do |sfile, index|
            tfile = @builder.targetBlame.blameFiles[index]
            
            # diff = Myers.new(sfile, tfile)
            # diff.myers

            # if tfile != nil && tfile.blameLines != nil && tfile.blameLines.count == 0 then
            #     reviewer["new"] = 0 unless hash.key?("new")
            #     reviewer["new"] += 1
            # else
            #     puts ""
            # end
        end
    end
end