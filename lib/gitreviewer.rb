# frozen_string_literal: true

require "gitreviewer/version"

module GitReviewer
  class Error < StandardError; end
  # Your code goes here...
  autoload :Command, 'gitreviewer/command'
end
