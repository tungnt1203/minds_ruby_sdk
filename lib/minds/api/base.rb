module Minds
  class Api
    class Base
      attr_accessor :api_key, :base_url

      def initialize(base_url:, api_key:)
        if base_url.nil?
          base_url = "https://mdb.ai"
        end

        base_url.gsub(/\/+$/, "")
        self.base_url = base_url
        self.api_key = api_key
      end

      private

      def conn
        Faraday.new(url: @base_url) do |builder|
          builder.request :json
          builder.response :json
          builder.response :raise_error
          builder.adapter Faraday.default_adapter
          builder.headers["Authorization"] = "Bearer #{@api_key}"
          builder.headers["Content-Type"] = "application/json"
        end
      end
    end
  end
end
