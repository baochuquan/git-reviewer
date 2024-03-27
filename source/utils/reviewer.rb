class Reviewer
    PROJECT_OWNER = 1
    DEVELOPER = 2

    attr_accessor :username
    attr_accessor :score
    attr_accessor :role 

    def initialize(username, score, role)
        self.username = username
        self.score = score 
        self.role = role
    end
end