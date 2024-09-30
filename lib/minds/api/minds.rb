module Minds
  class Api
    class Minds
      attr_accessor :client, :api, :project

      def initialize(client)
        self.api = client.api
        self.client = client

        self.project = "mindsdb"
      end
    end
  end
end
