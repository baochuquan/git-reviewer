
class GitReviewer
    attr_accessor :project_owner                # String
    attr_accessor :folder_owner                 # Array<FolderOwner>
    attr_accessor :file_owner                   # Array<FileReOwner>
    attr_accessor :ignore_reviewer_files        # Array<String>
    attr_accessor :ignore_reviewer_folders      # Array<String>
end

class FileOwner
    attr_accessor :path
    attr_accessor :owner
end

class FolderOwner
    attr_accessor :path
    attr_accessor :owner
end
