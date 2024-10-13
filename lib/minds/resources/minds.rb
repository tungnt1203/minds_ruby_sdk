require "openai"
require "uri"
module Minds
  module Resources
    DEFAULT_PROMPT_TEMPLATE = "Use your database tools to answer the user's question: {{question}}"

    class Mind < Base
      attr_accessor :name, :model_name, :provider, :parameters, :created_at, :updated_at, :datasources

      def initialize(client, attributes = {})
        super(client)
        @project = "mindsdb"
        @name = attributes["name"]
        @model_name = attributes["model_name"]
        @provider = attributes["provider"]
        @parameters = attributes["parameters"] || {}
        @prompt_template = @parameters.delete("prompt_template")
        @created_at = attributes["created_at"]
        @updated_at = attributes["updated_at"]
        @datasources = attributes["datasources"]
      end

      # Update the mind with new parameters
      #
      # @param name [String, nil] New name of the mind (optional)
      # @param model_name [String, nil] New LLM model name (optional)
      # @param provider [String, nil] New LLM provider (optional)
      # @param prompt_template [String, nil] New prompt template (optional)
      # @param datasources [Array<String, Datasource, DatabaseConfig>, nil] Alter list of datasources used by mind (optional)
      #   Datasource can be passed as:
      #   - String: name of the datasource
      #   - Datasource object (Minds::Resources::Datasource)
      #   - DatabaseConfig object (Minds::Resources::DatabaseConfig), in this case datasource will be created
      # @param parameters [Hash, nil] Alter other parameters of the mind (optional)
      # @return [void]
      def update(name: nil, model_name: nil, provider: nil, prompt_template: nil, datasources: nil, parameters: nil)
        data = {}

        ds_names = []
        datasources.each do |ds|
          minds = Minds.new(self)
          ds_name = minds.check_datasource(ds)
          ds_names << ds_name
          data["datasources"] = ds_names
        end if datasources

        data["name"] = name if name
        data["model_name"] = model_name if model_name
        data["provider"] = provider if provider
        data["parameters"] = parameters.nil? ? {} :  parameters
        data["parameters"]["prompt_template"] = prompt_template if prompt_template

        self.api.patch("/api/projects/#{@project}/minds/#{@name}") do |req|
          req.body = data.to_json
        end

        @name = name if name && name != @name
      end

      # Add a datasource to the mind
      #
      # @param datasource [String, Datasource, DatabaseConfig] The datasource to add
      #   Can be passed as:
      #   - String: name of the datasource
      #   - Datasource object (Minds::Resources::Datasource)
      #   - DatabaseConfig object (Minds::Resources::DatabaseConfig), in this case datasource will be created
      # @return [void]
      def add_datasources(datasource)
        minds = Minds.new(self)
        ds_name = minds.check_datasource(datasource)
        self.api.post("/api/projects/#{project}/minds/#{@name}/datasources") do |req|
          req.body = { name: ds_name }.to_json
        end

        mind = minds.find(@name)

        @datasources = mind.datasources
      end

      # Delete a datasource from the mind
      #
      # @param datasource [String, Datasource] The datasource to delete
      #   Can be passed as:
      #   - String: name of the datasource
      #   - Datasource object (Minds::Resources::Datasource)
      # @return [void]
      def destroy_datasources(datasource)
        if datasource.is_a?(Datasource)
          datasource = datasource.name
        elsif !datasource.is_a?(String)
          raise ArgumentError, "Unknown type of datasource: #{datasource}"
        end
        self.api.delete("/api/projects/#{@project}/minds/#{@name}/datasources/#{datasource}")

        minds = Minds.new(self)
        mind = minds.find(@name)
        @datasources = mind.datasources
      end

      # Call mind completion
      #
      # @param message [String] The input question or prompt
      # @param stream [Boolean] Whether to enable stream mode (default: false)
      # @return [String, Enumerator] If stream mode is off, returns a String.
      #   If stream mode is on, returns an Enumerator of ChoiceDelta objects (as defined by OpenAI)
      def completion(message:, stream: false)
        parsed = URI.parse(self.api.base_url)
        host = parsed.host
        if host == "mdb.ai"
          llm_host = "llm.mdb.ai"
        else
          llm_host = "ai.#{host}"
        end
        parsed.host = llm_host
        parsed.path = ""
        parsed.query = nil
        uri_base = parsed
        openai_client = OpenAI::Client.new(access_token: self.api_key, uri_base: uri_base)
        if stream
          openai_client.chat(
            parameters: {
              model: @model_name,
              messages: [ { role: "user", content: message } ], # Required.
              temperature: 0,
              stream: proc do |chunk, _bytesize|
                print chunk.dig("choices", 0, "delta")
              end
            }
          )
        else
          response = openai_client.chat(
            parameters: {
              model: @model_name,
              messages: [ { role: "user", content: message } ],
              temperature: 0
            }
          )
          response.dig("choices", 0, "message", "content")
        end
      end
    end

    class Minds < Base
      def initialize(client)
        super
        @project = "mindsdb"
      end

      # Returns a list of all minds
      #
      # @return [Array<Mind>] An array of Mind objects
      def all
        resp = self.api.get("/api/projects/#{@project}/minds")
        resp.body
        resp.body.map { |item| Mind.new(self, item) }
      end

      # Get a mind by name
      #
      # @param name [String] The name of the mind to find
      # @return [Mind] The found mind object
      def find(name)
        resp = self.api.get("/api/projects/#{@project}/minds/#{name}")
        Mind.new(self, resp.body)
      end

      # Drop (delete) a mind by name
      #
      # @param name [String] The name of the mind to delete
      # @return [void]
      def destroy(name)
        self.api.delete("/api/projects/#{@project}/minds/#{name}")
      end

      # Create a new mind and return it
      #
      # @param name [String] The name of the mind
      # @param model_name [String, nil] The LLM model name (optional)
      # @param provider [String, nil] The LLM provider (optional)
      # @param prompt_template [String, nil] Instructions to LLM (optional)
      # @param datasources [Array<String, Datasource, DatabaseConfig>, nil] List of datasources used by mind (optional)
      #   Datasource can be passed as:
      #   - String: name of the datasource
      #   - Datasource object (Minds::Resources::Datasource)
      #   - DatabaseConfig object (Minds::Resources::DatabaseConfig), in this case datasource will be created
      # @param parameters [Hash, nil] Other parameters of the mind (optional)
      # @param replace [Boolean] If true, remove existing mind with the same name (default: false)
      # @return [Mind] The created mind object
      def create(name:, model_name: nil, provider: nil, prompt_template: nil, datasources:  nil, parameters: nil, replace: false)
        if replace
          begin
            find(name)
            destroy(name)
          rescue Faraday::ResourceNotFound
          end
        end

        ds_names = []
        datasources.each do |ds|
          ds_name = check_datasource(ds)
          ds_names << ds_name
        end if datasources

        parameters = {} if parameters.nil?

        parameters["prompt_template"] = prompt_template if prompt_template
        parameters["prompt_template"] ||= DEFAULT_PROMPT_TEMPLATE
        self.api.post("api/projects/#{@project}/minds") do |req|
          req.body = {
            name: name,
            model_name: model_name,
            provider: provider,
            parameters: parameters,
            datasources: ds_names
          }.to_json

          find(name)
        end
      end

      def check_datasource(ds)
        ds_name = extract_datasource_name(ds)
        create_datasource_if_needed(ds)
        ds_name
      end

      private

      def extract_datasource_name(ds)
        case ds
        when Datasource, DatabaseConfig, String
          ds.respond_to?(:name) ? ds.name : ds
        else
          raise ArgumentError, "Unknown type of datasource: #{ds.class}"
        end
      end

      def create_datasource_if_needed(ds)
        return unless ds.is_a?(DatabaseConfig)
        datasources = Datasources.new(self)
        datasources.find(ds.name)
      rescue Faraday::ResourceNotFound
        datasources.create(ds)
      end
    end
  end
end
