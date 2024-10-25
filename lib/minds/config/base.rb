module Minds
  module Config
    class Base
      attr_accessor :base_url, :api_key, :log_errors, :api_version
      DEFAULT_BASE_URL = "https://mdb.ai".freeze
      DEFAULT_LOG_ERRORS = false
      DEFAULT_API_VERSION = "api".freeze

      def initialize
        @api_key  = nil
        @base_url = DEFAULT_BASE_URL
        @log_errors = DEFAULT_LOG_ERRORS
        @api_version = DEFAULT_API_VERSION
      end
    end
  end
end
