require "faraday"
require "json"
require_relative "api/base"
require_relative "api/minds"
require_relative "datasources/base"

module Minds
  class Client
    attr_accessor :api, :datasources, :minds
    KEYS = %i[base_url api_key]

    def initialize(base_url = nil, api_key = nil)
      # if api_key & base_url not present. Fall back to global config
      base_url = base_url.nil? ?  Minds.config.send(:base_url) : base_url
      api_key = api_key.nil? ?  Minds.config.send(:api_key) : api_key
      self.api = Minds::Api::Base.new(base_url: base_url, api_key: api_key)
      self.datasources= nil
      self.minds = Minds::Api::Minds.new(self)
    end
  end
end
