# Minds Ruby SDK

Minds Ruby SDK provides an interface to interact with the Minds AI system API. It allows you to create and manage "minds" (artificial intelligences), create chat completions, and manage data sources.

[![Gem Version](https://badge.fury.io/rb/minds_sdk.svg)](https://badge.fury.io/rb/minds_sdk)
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'minds_sdk'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install minds_sdk
```

## Getting Started

### Configuration

There are two ways to configure the Minds client:

1. Global Configuration:

You can set up a global configuration that will be used by default for all client instances:

```ruby
Minds::Client.configure do |config|
  config.base_url = "https://mdb.ai"  # Optional: defaults to https://mdb.ai
  config.api_key = "YOUR_API_KEY"
end
```

2. Instance Configuration:

Alternatively, you can configure each client instance individually:

```ruby
client = Minds::Client.new("YOUR_API_KEY", "https://mdb.ai")
```

### Initialize the Client

After configuration, you can initialize the client:

```ruby
# Using global configuration
client = Minds::Client.new

# Or with instance-specific configuration
client = Minds::Client.new("YOUR_API_KEY", "https://mdb.ai")

# For a self-hosted Minds Cloud instance
client = Minds::Client.new("YOUR_API_KEY", "https://<custom_cloud>.mdb.ai")
```

## Resources
### Creating a Data Source

You can connect to various databases, such as PostgreSQL, by configuring your data source. Use the DatabaseConfig to define the connection details for your data source.

```ruby
postgres_config = Minds::Resources::DatabaseConfig.new(
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
  tables: ['<TABLE-1>', '<TABLE-2>']
)

See supported [Data Sources](https://docs.mdb.ai/docs/data_sources)
```

### Creating a Mind

You can create a mind and associate it with a data source.

```ruby
# Create a mind with a data source
mind = client.minds.create(name: 'mind_name', datasources: [postgres_config])

# Alternatively, create a data source separately and add it to a mind later
datasource = client.datasources.create(postgres_config)
mind2 = client.minds.create(name: 'mind_name', datasources: [datasource])
```

You can also add a data source to an existing mind:

```ruby
# Create a mind without a data source
mind3 = client.minds.create(name: 'mind_name')

# Add a data source to the mind
mind3.add_datasources(postgres_config)  # Using the config
mind3.add_datasources(datasource)       # Using the data source object
```

### Managing Minds

You can create a mind or replace an existing one with the same name.

```ruby
mind = client.minds.create(name: 'mind_name', replace: true, datasources: [postgres_config])
```

To update a mind, specify the new attributes:

```ruby
mind.update(
  name: 'new_mind_name',
  datasources: [postgres_config]
)
```

### List Minds

You can list all the minds you've created:

```ruby
puts client.minds.all
```

### Get a Mind by Name

You can fetch details of a mind by its name:

```ruby
mind = client.minds.find('mind_name')
```

### Remove a Mind

To delete a mind, use the following command:

```ruby
client.minds.destroy('mind_name')
```

### Managing Data Sources

To view all data sources:

```ruby
puts client.datasources.all
```

### Get a Data Source by Name

You can fetch details of a specific data source by its name:

```ruby
datasource = client.datasources.find('my_datasource')
```

### Remove a Data Source

To delete a data source, use the following command:

```ruby
client.datasources.destroy('my_datasource')
```

Note: The SDK currently does not support automatically removing a data source if it is no longer connected to any mind.

## Chat Completion

You can use a mind to generate chat completions:

```ruby
response = mind.completion(message: "Hello, how are you?")
puts response

# For streaming responses
mind.completion(message: "Tell me a story", stream: true)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at [here](https://github.com/your_github_username/minds_ruby_sdk).

## Acknowledgments

This SDK is built for integration with Minds, AI layer for existing databases. We would like to express our gratitude to the MindsDB team for their innovative work in making AI more accessible.
For more information about MindsDB, please visit their official website: [https://mindsdb.com/](https://mindsdb.com/)
## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
