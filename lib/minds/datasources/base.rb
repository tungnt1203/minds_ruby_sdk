# frozen_string_literal: true

module Minds
  module DatabaseConfig
    class Base
      attr_accessor :description, :type, :connection_args, :tables

      def initialize(description:, type:, connection_args: {}, tables: nil)
        @description = description
        @type = type
        @connection_args = connection_args
        @tables = tables
      end

      def permit_params
        {
          type: @type,
          connection_args: @connection_args,
          description: @description,
          tables: @tables
        }
      end
    end

    class ClickHouse < Base
      def initialize(description:, connection_args:, tables: nil)
        super(description: description, type: :clickhouse, connection_args: connection_args, tables: tables)
      end
    end

    class MariaDB < Base
      def initialize(description:, connection_args:, tables: nil)
        super(description: description, type: :mariadb, connection_args: connection_args, tables: tables)
      end
    end

    class MySQL < Base
      def initialize(description:, connection_args:, tables: nil)
        super(description: description, type: :mysql, connection_args: connection_args, tables: tables)
      end
    end

    class PostgreSQL < Base
      def initialize(description:, connection_args:, tables: nil)
        super(description: description, type: :postgres, connection_args: connection_args, tables: tables)
      end
    end

    class AmazonRedshift < Base
      def initialize(description:, connection_args:, tables: nil)
        super(description: description, type: :redshift, connection_args: connection_args, tables: tables)
      end
    end

    class Snowflake < Base
      def initialize(description:, connection_args:, tables: nil)
        super(description: description, type: :snowflake, connection_args: connection_args, tables: tables)
      end
    end

    class Elasticsearch < Base
      def initialize(description:, connection_args:, tables: nil)
        super(description: description, type: :elasticsearch, connection_args: connection_args, tables: tables)
      end
    end

    class Datasources
      def initalize(client)
        self.api = client.api
      end
    end
  end
end
