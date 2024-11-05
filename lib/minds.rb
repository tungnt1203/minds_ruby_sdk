# frozen_string_literal: true

require "faraday"
require "json"
require_relative "minds/version"
require_relative "minds/rest_client"
require_relative "minds/client"
require_relative "minds/errors"
require_relative "minds/config/base"
require_relative "minds/datasources"
require_relative "minds/minds"

module Minds
  class MiddlewareErrors < Faraday::Middleware
    ##
    # Handles API error responses and provides detailed logging
    #
    # @param env [Hash] The Faraday environment hash
    # @raise [Faraday::Error] Re-raises the original error after logging
    def call(env)
      @app.call(env)
    rescue Faraday::Error => e
      raise e unless e.response.is_a?(Hash)

      logger = Logger.new($stdout)
      logger.formatter = proc do |_severity, datetime, _progname, msg|
        timestamp = datetime.strftime("%Y-%m-%d %H:%M:%S.%L")

        error_prefix = "\033[31m[Minds #{VERSION}] #{timestamp} ERROR"
        error_suffix = "\033[0m"

        formatted_message = msg.split("\n").map do |line|
          "#{' ' * 15}#{line}"
        end.join("\n")

        "#{error_prefix} Rest Client Error\n#{formatted_message}#{error_suffix}\n"
      end

      logger.error(e.response[:body])
      raise e
    end
  end
end
