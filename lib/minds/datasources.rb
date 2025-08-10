module Minds
  class DatabaseConfig
    attr_accessor :name, :engine, :description, :connection_data, :tables, :created_at

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

  class Datasources
    def initialize(client:)
      @client = client
    end

    # Create a new datasource and return it
    #
    # @param ds_config [DatabaseConfig] datasource configuration
    # @option ds_config [String] :name Name of the datasource
    # @option ds_config [String] :engine Type of database handler (e.g., 'postgres', 'mysql')
    # @option ds_config [String] :description Description of the database. Used by mind to understand what data can be retrieved from it.
    # @option ds_config [Hash] :connection_data (optional) Credentials to connect to the database
    # @option ds_config [Array<String>] :tables (optional) List of allowed tables
    # @param update [Boolean] If true, to update datasource if exists, default is false
    # @return [Datasource] The created datasource object
    # @raise [ObjectNotSupported] If datasource type is not supported
    #
    # @example
    #   config = DatabaseConfig.new(
    #     name: 'sales_db',
    #     engine: 'postgres',
    #     connection_data: {
    #       host: 'localhost',
    #       port: 5432,
    #       user_name: "test"
    #       password: "test"
    #     }
    #   )
    #   datasource = datasources.create(config)
    #
    def create(ds_config, update = false)
      name = ds_config.name

      Validators.validate_datasource_name!(name)

      path = "datasources"
      path += "/#{name}" if update

      @client.send(update ? :put : :post, path: path, parameters: ds_config.to_h)
      find(name)
    end

    # Return a list of datasources
    #
    # @return [Array<Datasource>] An array of Datasource objects
    #
    # @example
    #   datasources = datasources.all
    #   datasources.each { |ds| puts ds.name }
    #
    def all
      data = @client.get(path: "datasources")
      return [] if data.empty?

      data.each_with_object([]) do |item, ds_list|
        next if item["engine"].nil?

        ds_list << Datasource.new(**item.transform_keys(&:to_sym))
      end
    end

    # Find a datasource by name
    #
    # @param name [String] The name of the datasource to find
    # @return [Datasource] The found datasource object
    # @raise [ObjectNotSupported] If the datasource type is not supported
    #
    # @example
    #   datasource = datasources.find('sales_db')
    #   puts datasource.engine
    #
    def find(name)
      data = @client.get(path: "datasources/#{name}")
      if data["engine"].nil?
        raise ObjectNotSupported, "Wrong type of datasource: #{name}"
      end
      Datasource.new(**data.transform_keys(&:to_sym))
    end

    # Delete a datasource
    #
    # @param name [String]  Datasource name to delete
    # @param force [Boolean] Whether to force delete from all minds
    #
    # @example
    #   # Simple delete
    #   datasources.destroy('old_db')
    #
    #   # Force delete
    #   datasources.destroy('old_db', force: true)
    #
    def destroy(name, force: false)
      data = force ? { cascade: true } : nil
      @client.delete(path: "datasources/#{name}", parameters: data)
    end
  end
end
