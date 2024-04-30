module GitReviewer
  class Printer
    @@verbose = false

    # 类方法，用于访问类变量
    def self.verbose
      @@verbose
    end

    # （可选）类方法，用于设置类变量
    def self.verbose=(value)
      @@verbose = value
    end

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

    def self.verbose_put(content)
        if @@verbose
            puts content
        end
    end

    def self.verbose_red(content)
        puts "\033[0;31m#{content}\033[0m"
      end

      def self.verbose_green(content)
        if @@verbose
            puts "\033[0;32m#{content}\033[0m"
        end
      end

      def self.verbose_yellow(content)
        if @@verbose
            puts "\033[0;33m#{content}\033[0m"
        end
      end

      def self.verbose_bold(content)
        if @@verbose
            puts "\033[0;1m#{content} \033[0m"
        end
      end
  end
end
