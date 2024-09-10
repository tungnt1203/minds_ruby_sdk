# frozen_string_literal: true

require_relative "minds/version"
require_relative "minds/config/base"
require_relative "minds/api/client"
require_relative "minds/database_config/base"

module Minds
  class Error < StandardError; end

  class << self
    def config
      @config ||= Config::Base.new
    end

    def configure
      yield(config) if block_given?
    end
  end
end
