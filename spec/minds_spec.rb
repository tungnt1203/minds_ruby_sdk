# frozen_string_literal: true

RSpec.describe Minds do
  it "has a version number" do
    expect(Minds::VERSION).not_to be nil
  end

  it "does something useful" do
    client = Minds::Client.new("test_api_key")
    expect(client).to be_a(Minds::Client)
  end

  describe Minds::Client do
    it "initializes with an API key" do
      client = Minds::Client.new("test_api_key")
      expect(client.api_key).to eq("test_api_key")
    end

    it "uses default base URL if not provided" do
      client = Minds::Client.new("test_api_key")
      expect(client.base_url).to eq(Minds::Config::Base::DEFAULT_BASE_URL)
    end

    it "allows setting a custom base URL" do
      custom_url = "https://custom.api.com"
      client = Minds::Client.new("test_api_key", custom_url)
      expect(client.base_url).to eq(custom_url)
    end
  end
end
