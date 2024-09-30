# frozen_string_literal: true

require_relative "minds/version"
require_relative "minds/client"
require_relative "minds/config/base"

module Minds
  class << self
    def config
      @config ||= Config::Base.new
    end

    def configure
      yield(config) if block_given?
    end
  end
end
