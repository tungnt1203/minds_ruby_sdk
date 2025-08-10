# frozen_string_literal: true

require "openai"
require "uri"

module Minds
  DEFAULT_PROMPT_TEMPLATE = "Use your database tools to answer the user's question: {{question}}"
  DEFAULT_MODEL = "gpt-4o"
  class Mind
    attr_reader :name, :model_name, :provider, :parameters, :created_at, :updated_at, :datasources, :prompt_template

    def initialize(client, attributes = {})
      @client = client
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

    # Update mind
    #
    # @param name [String, nil] New name of the mind (optional)
    # @param model_name [String, nil] New LLM model name (optional)
    # @param provider [String, nil] New LLM provider (optional)
    # @param prompt_template [String, nil] New prompt template (optional)
    # @param datasources [Array<String, Datasource, DatabaseConfig>, nil] Alter list of datasources used by mind (optional)
    #   Datasource can be passed as:
    #   - String: name of the datasource
    #   - Datasource object (Minds::Datasource)
    #   - DatabaseConfig object (Minds::DatabaseConfig), in this case datasource will be created
    # @param parameters [Hash, nil] Alter other parameters of the mind (optional)
    # @return [void]
    def update(name: nil, model_name: nil, provider: nil, prompt_template: nil, datasources: nil, parameters: nil)
      Validators.validate_mind_name!(name) if !name.nil?
      data = {}
      ds_names = []
      datasources.each do |ds|
        ds_name = @client.minds.check_datasource(ds)
        ds_names << ds_name
      end if datasources

      data["datasources"] = ds_names if !ds_names.empty?
      data["name"] = name if name
      data["model_name"] = model_name if model_name
      data["provider"] = provider if provider
      data["parameters"] = parameters.nil? ? {} : parameters
      data["parameters"]["prompt_template"] = prompt_template if prompt_template

      @client.patch(path: "projects/#{@project}/minds/#{@name}", parameters: data)

      @name = name if name && name != @name

      updated_mind = @client.minds.find(@name)

      @model_name = updated_mind.model_name
      @datasources = updated_mind.datasources
      @parameters = updated_mind.parameters
      @prompt_template = updated_mind.prompt_template
      @provider = updated_mind.provider
      @created_at = updated_mind.created_at
      @updated_at = updated_mind.updated_at
      true
    end

    # Add datasource to mind
    #
    # @param datasource [String, Datasource, DatabaseConfig] Datasource to add
    #   Can be passed as:
    #   - String: name of the datasource
    #   - Datasource object (Minds::Datasource)
    #   - DatabaseConfig object (Minds::DatabaseConfig), in this case datasource will be created
    # @return [void]
    def add_datasources(datasource)
      ds_name = @client.minds.check_datasource(datasource)
      data = { name: ds_name }
      @client.post(path: "projects/#{@project}/minds/#{@name}/datasources", parameters: data)

      mind = @client.minds.find(@name)
      @datasources = mind.datasources

      true
    end

    # Remove datasource from mind
    #
    # @param datasource [String, Datasource] Datasource to remove
    #   Can be passed as:
    #   - String: name of the datasource
    #   - Datasource object (Minds::Datasource)
    # @return [void]
    # @raise [ArgumentError] If datasource type is invalid
    def destroy_datasources(datasource)
      if datasource.is_a?(Datasource)
        datasource = datasource.name
      elsif !datasource.is_a?(String)
        raise ArgumentError, "Unknown type of datasource: #{datasource}"
      end
      @client.delete(path: "projects/#{@project}/minds/#{@name}/datasources/#{datasource}")

      mind = @client.minds.find(@name)
      @datasources = mind.datasources
      true
    end

    # Call mind completion
    #
    # @param message [String] The input question or prompt
    # @param stream [Boolean] Whether to enable stream mode (default: false)
    # @return [String, Enumerator] If stream mode is off, returns a String.
    #   If stream mode is on, returns an Enumerator of ChoiceDelta objects (as defined by OpenAI)
    def completion(message:, stream: false)
      openai_client = OpenAI::Client.new(access_token: @client.api_key, uri_base: @client.base_url)
      params = {
        model: @name,
        messages: [ { role: "user", content: message } ],
        temperature: 0
      }

      if stream
        openai_client.chat(
          parameters: params.merge(
            stream: proc do |chunk, _bytesize|
              yield chunk if block_given?
            end
          )
        )
      else
        response = openai_client.chat(parameters: params)
        response.dig("choices", 0, "message", "content")
      end
    end
  end

  class Minds
    def initialize(client:)
      @client = client
      @project = "mindsdb"
    end

    # Lists minds
    #
    # @return [Array<Mind>] List of minds
    #
    # @example
    #   minds = minds.all
    #   minds.each { |mind| puts mind.name }
    #
    def all
      data = @client.get(path: "projects/#{@project}/minds")
      return [] if data.empty?

      data.map { |item| Mind.new(@client, item) }
    end

    # Find a mind by name
    #
    # @param name [String] The name of the mind to find
    # @return [Mind] The found mind object
    #
    # @example
    #   mind = minds.find('sales_assistant')
    #   puts mind.model_name
    #
    def find(name)
      data = @client.get(path: "projects/#{@project}/minds/#{name}")
      Mind.new(@client, data)
    end

    # Delete a mind
    #
    # @param name [String] The name of the mind to delete
    # @return [void]
    #
    # @example
    #   minds.destroy('old_assistant')
    #
    def destroy(name)
      @client.delete(path: "projects/#{@project}/minds/#{name}")
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
    #   - Datasource object (Minds::Datasource)
    #   - DatabaseConfig object (Minds::DatabaseConfig), in this case datasource will be created
    # @param parameters [Hash, nil] Other parameters of the mind (optional)
    # @param replace [Boolean] If true, remove existing mind with the same name (default: false)
    # @param update [Boolean] If true, to update mind if exists(default: false)
    # @return [Mind] The created mind object
    #
    # @example Simple creation
    #   mind = minds.create(name: 'sales_assistant', model_name: 'gpt-4')
    #
    # @example Creation with datasources
    #   mind = minds.create(
    #     name: 'sales_assistant',
    #     model_name: 'gpt-4',
    #     datasources: ['sales_db'],
    #     prompt_template: 'Analyze sales data: {{question}}'
    #   )
    #
    def create(name:, model_name: nil, provider: nil, prompt_template: nil, datasources: nil, parameters: nil, replace: false, update: false)
      Validators.validate_mind_name!(name) if !name.nil?

      if replace
        find(name)
        destroy(name)
      end

      ds_names = []
      datasources.each do |ds|
        ds_name = check_datasource(ds)
        ds_names << ds_name
      end if datasources

      parameters = {} if parameters.nil?

      parameters["prompt_template"] = prompt_template if prompt_template
      parameters["prompt_template"] ||= DEFAULT_PROMPT_TEMPLATE
      data = {
        name: name,
        model_name: model_name || DEFAULT_MODEL,
        provider: provider,
        parameters: parameters,
        datasources: ds_names
      }

      path = "projects/#{@project}/minds"
      path += "/#{name}" if update
      @client.send(update ? :put : :post, path: path, parameters: data)
      find(name)
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

      @client.datasources.find(ds.name)
    rescue Faraday::ResourceNotFound
      @client.datasources.create(ds)
    end
  end
end
