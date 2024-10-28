RSpec.describe "Datasources Integration", :vcr do
  let(:client) { Minds::Client.new(api_key: ENV.fetch("MINDS_API_KEY")) }
  let(:datasources) { Minds::Datasources.new(client: client) }

  describe "#create" do
    let(:ds_config) do
      Minds::DatabaseConfig.new(
        name: 'my_datasource',
        description: '<DESCRIPTION-OF-YOUR-DATA>',
        engine: 'postgres',
        connection_data: {
          user: 'demo_user',
          password: 'demo_password',
          host: 'samples.mindsdb.com',
          port: 5432,
          database: 'demo',
          schema: 'demo_data'
        },
        tables: [ '<TABLE-1>', '<TABLE-2>' ]
      )
    end

    it "creates a new datasource" do
      VCR.use_cassette("datasources/create_datasource", record: :new_episodes) do
        result = datasources.create(ds_config)
        expect(result).to be_a(Minds::Datasource)
        expect(result.name).to eq("my_datasource")
        expect(result.engine).to eq("postgres")
      end
    end
  end

  describe "#all" do
    it "get all datasources" do
      VCR.use_cassette("datasources/all_datasource") do
        result = datasources.all
        expect(result).to be_an(Array)
        result.each do |ds|
          expect(ds).to be_a(Minds::Datasource)
        end
      end
    end
  end

  describe "#destroy" do
    it "delete datasources" do
      VCR.use_cassette("datasources/destroy_datasource") do
        result = datasources.destroy("my_datasource", force: true)
        expect(result).to eq("")
      end
    end
  end
end
