# frozen_string_literal: true

RSpec.describe Minds::Client do
  describe '#uri' do
    it 'prefixes api version when base url lacks version path but contains substring in host' do
      client = described_class.new(api_key: 'test', base_url: 'https://api.example.com')
      expect(client.send(:uri, path: 'datasources')).to eq('/api/datasources')
    end

    it 'does not prefix api version when base url already includes version path' do
      client = described_class.new(api_key: 'test', base_url: 'https://example.com/api')
      expect(client.send(:uri, path: 'datasources')).to eq('datasources')
    end
  end
end
