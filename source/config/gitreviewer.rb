
class GitReviewer
    attr_accessor :project_owner                # String
    attr_accessor :folder_reviewer              # Array<FolderReviewer>
    attr_accessor :file_reviewer                # Array<FileReviewer>
    attr_accessor :ignore_reviewer_files        # Array<String>
    attr_accessor :ignore_reviewer_folders      # Array<String>
end

class FileReviewer
    attr_accessor :file
    attr_accessor :reviewer
end

class FolderReviewer
    attr_accessor :folder
    attr_accessor :reviewer 
end