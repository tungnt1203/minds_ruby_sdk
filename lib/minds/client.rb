require "faraday"
require "json"
require_relative "config/base"
require_relative "resources/base"
require_relative "resources/minds"
require_relative "resources/datasources"

module Minds
  class Client
    class << self
      def config
        @config ||= Config::Base.new
      end

      def configure
        yield(config) if block_given?
      end
    end

    attr_accessor :base_url, :api_key

    def initialize(api_key: nil, base_url: nil)
      # if api_key & base_url not present. Fall back to global config
      @base_url = base_url ||  Minds::Client.config.send(:base_url)
      @api_key = api_key ||  Minds::Client.config.send(:api_key)
    end

    def datasources
      @datasources ||= Minds::Resources::Datasources.new(self)
    end

    def minds
      @minds ||= Minds::Resources::Minds.new(self)
    end
  end
end
