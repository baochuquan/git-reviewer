
class Printer
    def self.put(content)
        puts content
    end

    def self.red(content)
        puts "\033[0;31m#{content}\033[0m"
    end

    def self.green(content)
        puts "\033[0;32m#{content}\033[0m"
    end

    def self.yellow(content) 
        puts "\033[0;33m#{content}\033[0m"
    end

    def self.bold(content)
        puts "\033[0;1m#{content} \033[0m"
    end
end