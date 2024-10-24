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
      connection = Faraday.new(url: @base_url) do |builder|
        builder.use MiddlewareErrors if @log_errors
        builder.headers["Authorization"] = "Bearer #{@api_key}"
        builder.headers["Content-Type"] = "application/json"
        builder.request :json
        builder.response :json
        builder.response :raise_error
      end

      connection
    end
  end
end
