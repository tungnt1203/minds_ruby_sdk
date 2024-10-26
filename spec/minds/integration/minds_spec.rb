RSpec.describe "Minds Integration", :vcr do
  let(:client) { Minds::Client.new(api_key: ENV.fetch("MINDS_API_KEY"), log_errors: true) }
  let(:minds) { Minds::Minds.new(client: client) }

  describe "#create" do
    it "create a new mind" do
      VCR.use_cassette("minds/create_mind") do
        mind = minds.create(
          name: "test_mind"
        )

        expect(mind).to be_a(Minds::Mind)
        expect(mind.name).to eq("test_mind")
      end
    end
  end

  describe "#completion" do
    let(:mind) do
      VCR.use_cassette("minds/find_mind") do
        minds.find("test_recommend")
      end
    end

    it "gets completion response" do
      VCR.use_cassette("minds/completion") do
        response = mind.completion(message: "What is Mind")
        expect(response).to be_a(String)
        expect(response).not_to be_empty
      end
    end
  end
end
