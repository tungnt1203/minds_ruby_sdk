module Minds
  class Client
    include Minds::RestClient

    SENSITIVE_ATTRIBUTES = %i[@api_key].freeze

    attr_accessor :base_url, :api_key

    def initialize(api_key: nil, base_url: nil)
      # if api_key & base_url not present. Fall back to global config
      @base_url = base_url || Client.config.send(:base_url)
      @api_key = api_key || Client.config.send(:api_key)
    end

    class << self
      def config
        @config ||= Config::Base.new
      end

      def configure
        yield(config) if block_given?
      end
    end

    def datasources
      @datasources ||= Datasources.new(client: self)
    end

    def minds
      @minds ||= Minds.new(client: self)
    end

    def inspect
      vars = instance_variables.map do |var|
        value = instance_variable_get(var)

        SENSITIVE_ATTRIBUTES.include?(var) ? "#{var}=[FILTERED]" : "#{var}=#{value.inspect}"
      end

      "#<#{self.class}:0x#{object_id.to_s(16)} #{vars.join(', ')}>"
    end
  end
end
