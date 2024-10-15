module Minds
  module Config
    class Base
      attr_accessor :base_url, :api_key
      DEFAULT_BASE_URL = "https://mdb.ai"

      def initialize
        @base_url = DEFAULT_BASE_URL
        @api_key  = nil
      end
    end
  end
end
