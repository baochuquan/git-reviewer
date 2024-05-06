
module GitReviewer
  class Configuration
    attr_accessor :project_owner                # String
    attr_accessor :folder_owner                 # Array<FolderOwner>
    attr_accessor :file_owner                   # Array<FileReOwner>
    attr_accessor :ignore_files                 # Array<String>
    attr_accessor :ignore_folders               # Array<String>

    def initialize(project_owner, folder_owner, file_owner, ignore_files, ignore_folders)
      @project_owner = project_owner
      @folder_owner = folder_owner
      @file_owner = file_owner
      @ignore_files = ignore_files
      @ignore_folders = ignore_folders
    end

    def to_hash
      {
        project_owner: @project_owner,
        folder_owner: @folder_owner.map(&:to_hash),
        file_owner: @file_owner.map(&:to_hash),
        ignore_files: @ignore_files,
        ignore_folders: @ignore_folders
      }
    end

    def reviewer_of_file(file_name)
      if @ignore_files.include?(file_name)
        return nil
      end

      if @ignore_folders.any?{ |folder| file_name.start_with?(folder) }
        return nil
      end

      fowner = @file_owner.select { |owner| owner.path == file_name }.first
      if fowner != nil
        return fowner.owner
      end

      downer = @folder_owner.select { |owner| file_name.start_with?(owner.path) }.first
      if downer != nil
        return downer.owner
      end

      return @project_owner
    end
  end

  class FileOwner
    attr_accessor :path
    attr_accessor :owner

    def initialize(path, owner)
      @path = path
      @owner = owner
    end

    def to_hash
      {
        path: @path,
        owner: @owner
      }
    end
  end

  class FolderOwner
    attr_accessor :path
    attr_accessor :owner

    def initialize(path, owner)
      @path = path
      @owner = owner
    end

    def to_hash
      {
        path: @path,
        owner: @owner
      }
    end
  end
end
