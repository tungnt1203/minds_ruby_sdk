module Minds
  class Client
    include Minds::RestClient

    SENSITIVE_ATTRIBUTES = %i[@api_key].freeze
    CONFIG_KEYS = %i[base_url api_key log_errors api_version].freeze
    attr_reader(*CONFIG_KEYS)

    def initialize(options = {})
      # if key not present. Fall back to global config
      CONFIG_KEYS.each do |key|
        instance_variable_set "@#{key}", options[key] || Client.config.send(key)
      end
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
