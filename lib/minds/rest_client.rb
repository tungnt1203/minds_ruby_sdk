module Minds
  module RestClient
    def get(path:)
      conn.get(uri(path:))&.body
    end

    def post(path:, parameters:)
      conn.post(uri(path:)) do |req|
        req.body = parameters.to_json
      end&.body
    end

    def patch(path:, parameters:)
      conn.patch(uri(path:)) do |req|
        req.body = parameters.to_json
      end&.body
    end

    def delete(path:)
      conn.delete(uri(path:))&.body
    end

    private

    def uri(path:)
      return path if @base_url.include?(@api_version)

      "/#{@api_version}/#{path}"
    end

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
