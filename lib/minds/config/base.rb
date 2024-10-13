module Minds
  module Config
    class Base
      attr_accessor :base_url, :api_key

      def initialize
        @base_url = nil
        @api_key  = nil
      end
    end
  end
end
