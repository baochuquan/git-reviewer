require 'gitreviewer/config/configuration'
require 'gitreviewer/utils/printer'
require 'yaml'


module GitReviewer

  class InitOption
    attr_accessor :fileExist

    def execute
      # 判断当前 .gitreviewer 文件是否存在
      check_file_exist

      # 如果不存在，则创建 .gitreviewer.yml
      if !@fileExist
        create_default_file
      end
    end

    def check_file_exist
      file_name = ".gitreviewer.yml"
      @fileExist = File.exist?(file_name)
      if @fileExist
        Printer.yellow "`.gitreviewer.yml` already exists. Please do not init again."
        exit 1
      end
    end

    def create_default_file()
      project_owner = "<project owner>"
      folder_owner = FolderOwner.new("", "")
      file_owner = FileOwner.new("", "")
      config = Configuration.new(project_owner, [folder_owner], [file_owner], [""], [""])
      data = config.to_hash
      data = deep_transform_keys_to_strings(data)
      yaml = YAML.dump(data)
      head = "# `.gitreviewer.yml` is used for a git plugin: git-reviewer.\n# For detailed information about git-reviewer, please refer to https://github.com/baochuquan/git-reviewer\n"
      content = head + yaml
      File.open('.gitreviewer.yml', 'w') do |file|
        file.write(content)
      end
      Printer.put "`.gitreviewer.yml` created successfully. If you want to customize settings, please edit this file.\n"
    end

    def deep_transform_keys_to_strings(value)
      case value
      when Hash
        value.transform_keys(&:to_s).transform_values { |v| deep_transform_keys_to_strings(v) }
      when Array
        value.map { |v| deep_transform_keys_to_strings(v) }
      else
        value  # 如果既不是哈希也不是数组，直接返回原值
      end
    end
  end
end
