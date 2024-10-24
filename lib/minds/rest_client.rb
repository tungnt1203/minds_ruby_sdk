module Minds
  module RestClient
    def get(path:, parameters: nil)
      conn.get(path, parameters)
    end

    def post(path:, parameters: nil)
      conn.post(path) do |req|
        req.body = parameters
      end
    end

    def patch(path:, parameters: nil)
      conn.patch(path) do |req|
        req.body = parameters
      end
    end

    def delete(path:)
      conn.delete(path)
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
