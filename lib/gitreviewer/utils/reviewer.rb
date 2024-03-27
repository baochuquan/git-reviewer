class Reviewer
    attr_accessor :username
    attr_accessor :score

    def initialize(username, score)
        self.username = username
        self.score = score 
    end
end