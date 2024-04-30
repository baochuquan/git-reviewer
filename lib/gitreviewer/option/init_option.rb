require_relative '../config/configuration'

module GitReviewer

  class InitOption
    attr_accessor :fileExist
    attr_accessor :fileValid

    def execute
      # 判断当前 .gitreviewer 文件是否存在
      check_file_exist

      # 如果不存在，则创建 .gitreviewer.json
      if !@fileExist
        create_file("baocq")   # TODO: @baocq
      end
    end

    def check_file_exist
      file_name = ".gitreviewer.json"
      @fileExist = File.exist?(file_name)
      if @fileExist
        puts "`.gitreviewer.json` exist. Please do not init again."
        exit 1
      end
    end

    def create_file(project_owner)
      config = Configuration.new(project_owner, [], [], [], [])
      json = config.to_hash.to_json
      data = JSON.parse(json)
      formatted_json = JSON.pretty_generate(data)
      print formatted_json

      File.open('.gitreviewer.json', 'w') do |file|
        file.write(formatted_json)
      end
    end
  end
end
