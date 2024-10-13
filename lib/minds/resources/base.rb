module Minds
  module Resources
    class Base
      attr_accessor :api_key, :base_url, :api

      def initialize(client)
        @base_url = client.base_url
        @api_key = client.api_key
        @api = conn
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
