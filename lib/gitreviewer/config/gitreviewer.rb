
module GitReviewer
  class Configuration
    attr_accessor :project_owner                # String
    attr_accessor :folder_owner                 # Array<FolderOwner>
    attr_accessor :file_owner                   # Array<FileReOwner>
    attr_accessor :ignore_reviewer_files        # Array<String>
    attr_accessor :ignore_reviewer_folders      # Array<String>

    def initialize(project_owner, folder_owner, file_owner, ignore_reviewer_files, ignore_reviewer_folders)
      @project_owner = project_owner
      @folder_owner = folder_owner
      @file_owner = file_owner
      @ignore_reviewer_files = ignore_reviewer_files
      @ignore_reviewer_folders = ignore_reviewer_folders
    end

    def to_hash
        {
            project_owner: @project_owner,
            folder_owner: @folder_owner.map(&:to_hash),
            file_owner: @file_owner.map(&:to_hash),
            ignore_reviewer_files: @ignore_reviewer_files,
            ignore_reviewer_folders: @ignore_reviewer_folders
        }
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
