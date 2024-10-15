module Minds
  module Resources
    class DatabaseConfig
      attr_reader :name, :engine, :description, :connection_data, :tables, :created_at

      def initialize(name:, engine:, description:, connection_data: {}, tables: [], created_at: nil)
        @name = name
        @engine = engine
        @description = description
        @connection_data = connection_data
        @tables = tables
        @created_at = created_at
      end

      def to_h
        {
          name: @name,
          engine: @engine,
          description: @description,
          connection_data: @connection_data,
          tables: @tables
        }
      end
    end

    class Datasource < DatabaseConfig; end

    class Datasources < Base
      # Create a new datasource and return it
      #
      # @param ds_config [DatabaseConfig] datasource configuration
      # @option ds_config [String] :name Name of the datasource
      # @option ds_config [String] :engine Type of database handler (e.g., 'postgres', 'mysql')
      # @option ds_config [String] :description Description of the database. Used by mind to understand what data can be retrieved from it.
      # @option ds_config [Hash] :connection_data (optional) Credentials to connect to the database
      # @option ds_config [Array<String>] :tables (optional) List of allowed tables
      # @param replace [Boolean] If true, replaces an existing datasource with the same name
      # @return [Datasource] The created datasource object
      # @raise [ObjectNotFound] If the datasource to be replaced doesn't exist
      def create(ds_config, replace = false)
        name = ds_config.name

        if replace
          begin
            find(name)
            destroy(name)
          rescue ObjectNotFound
            # Do nothing
          end
        end
        self.api.post("/api/datasources") do |req|
          req.body = ds_config.to_h.to_json
        end
        find(name)
      end

      # Returns a list of all datasources
      #
      # @return [Array<Datasource>] An array of Datasource objects
      def all
        data = self.api.get("/api/datasources").body
        data.each_with_object([]) do |item, ds_list|
          next if item["engine"].nil?

          ds_list << Datasource.new(**item.transform_keys(&:to_sym))
        end
      end

      # Get a datasource by name
      #
      # @param name [String] The name of the datasource to find
      # @return [Datasource] The found datasource object
      # @raise [ObjectNotSupported] If the datasource type is not supported
      def find(name)
        data = self.api.get("api/datasources/#{name}").body

        if data["engine"].nil?
          raise ObjectNotSupported, "Wrong type of datasource: #{name}"
        end

        Datasource.new(**data.transform_keys(&:to_sym))
      end

      # Drop (delete) a datasource by name
      #
      # @param name [String] The name of the datasource to delete
      # @return [void]
      # @raise [Faraday::ResourceNotFound] If the datasource doesn't exist
      # @raise [Faraday::ClientError] If there's a client-side error
      # @raise [Faraday::ServerError] If there's a server-side error
      def destroy(name)
       self.api.delete("api/datasources/#{name}")
      end
    end
  end
end
