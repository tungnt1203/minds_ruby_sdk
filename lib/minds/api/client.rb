require "faraday"
require "json"

module Minds
  module Api
    class Client
      def initialize
        @connection = create_connection
      end

      # Create a new mind
      # @param name [String] The name of the mind
      # @param data_source_configs [Array] Array of database configurations
      # @return [Hash] Response from the API
      def create_mind(name:, data_source_configs:)
        payload = { name: name, data_source_configs: data_source_configs }
        make_request(:post, "/minds", payload)
      end

      # Delete a mind
      # @param mind_name [String] The name of the mind to delete
      # @return [Hash] Response from the API
      def delete_mind(mind_name:)
        make_request(:delete, "/minds/#{mind_name}")
      end

      # Create a chat completion
      # @param model [String] The model to use
      # @param messages [Array] Array of message objects
      # @param stream [Boolean] Whether to stream the response
      # @return [Hash] Response from the API
      def chat_completion(model:, messages:, stream: false)
        payload = {
          model: model,
          messages: messages,
          stream: stream
        }
        make_request(:post, "/chat/completions", payload)
      end

      # Create an assistant
      # @param model [String] The model to use
      # @param name [String] The name of the assistant
      # @param instructions [String] Instructions for the assistant
      # @param tools [Array] Array of tools for the assistant
      # @return [Hash] Response from the API
      def create_assistant(model:, name:, instructions:, tools: [])
        payload = {
          model: model,
          name: name,
          instructions: instructions,
          tools: tools
        }
        make_request(:post, "/assistants", payload)
      end

      # Get all assistants
      # @return [Hash] Response from the API
      def get_assistants
        make_request(:get, "/assistants")
      end

      # Delete an assistant
      # @param assistant_name [String] The name of the assistant to delete
      # @return [Hash] Response from the API
      def delete_assistants(assistant_name)
        make_request(:delete, "/assistants/#{assistant_name}")
      end

      # Create a new thread
      # @return [Hash] Response from the API
      def create_thread
        make_request(:post, "/threads")
      end

      # Delete a thread
      # @param thread_name [String] The name of the thread to delete
      # @return [Hash] Response from the API
      def delete_thread(thread_name)
        make_request(:delete, "/threads/#{thread_name}")
      end

      # Create a message in a thread
      # @param thread_id [String] The ID of the thread
      # @param role [String] The role of the message sender
      # @param content [String] The content of the message
      # @return [Hash] Response from the API
      def create_message(thread_id:, role:, content:)
        payload = {
          role: role,
          content: content
        }
        make_request(:post, "/threads/#{thread_id}/messages", payload)
      end

      # Get messages in a thread
      # @param thread_id [String] The ID of the thread
      # @return [Hash] Response from the API
      def get_thread_messages(thread_id)
        make_request(:get, "/threads/#{thread_id}/messages")
      end

      # Create a run in a thread
      # @param thread_id [String] The ID of the thread
      # @param assistant_id [String] The ID of the assistant
      # @param instructions [String] Instructions for the run
      # @param tools [Array] Array of tools for the run
      # @param metadata [Hash] Additional metadata for the run
      # @return [Hash] Response from the API
      def create_thread_run(thread_id:, assistant_id:, instructions:, tools: [], metadata: {})
        payload = {
          assistant_id: assistant_id,
          instructions: instructions,
          tools: tools,
          metadata: metadata
        }
        make_request(:post, "/threads/#{thread_id}/runs", payload)
      end

      # Get information about a specific run in a thread
      # @param thread_id [String] The ID of the thread
      # @param run_id [String] The ID of the run
      # @return [Hash] Response from the API
      def get_thread_run(thread_id:, run_id:)
        make_request(:get, "/threads/#{thread_id}/runs/#{run_id}")
      end

      private

      def create_connection
        Faraday.new(url: Minds.config.api_endpoint) do |conn|
          conn.request :json
          conn.response :json
          conn.adapter Faraday.default_adapter
          conn.headers["Authorization"] = "Bearer #{Minds.config.api_key}"
          conn.headers["Content-Type"] = "application/json"
        end
      end

      def make_request(method, path, payload = nil)
        response = @connection.send(method, path) do |req|
          req.body = payload.to_json if payload
        end
        handle_response(response)
      end

      def handle_response(response)
        case response.status
        when 200..299
          response.body
        else
          raise "API Error: #{response.status} - #{response.body}"
        end
      end
    end
  end
end
