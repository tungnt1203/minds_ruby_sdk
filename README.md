# Minds

Minds is a Ruby gem that provides an interface to interact with an AI system API. It allows you to create and manage "minds" (artificial intelligences), create chat completions, manage assistants, threads, and runs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'minds'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install minds
```

## Configuration

Before using the gem, you need to configure the API endpoint and API key. You can obtain your API key from https://mdb.ai/minds:

```ruby
Minds.configure do |config|
  config.api_endpoint = "https://llm.mdb.ai"
  config.api_key = "your_api_key"
end
```

## Usage

### Creating a client

```ruby
client = Minds::Api::Client.new
```

### Creating a new mind

```ruby
name = "My Mind"
data_source_configs = [
  Minds::DatabaseConfig::PostgreSQL.new(
    description: "Main database",
    connection_args: {
      host: "localhost",
      port: 5432,
      user: "username",
      password: "password",
      database: "mydb"
    }
  ).permit_params
]

response = client.create_mind(name: name, data_source_configs: data_source_configs)
```

### Creating a chat completion

```ruby
response = client.chat_completion(
  model: "<name of the mind that you created>",
  messages: [
    { role: "system", content: "You are a helpful assistant." },
    { role: "user", content: "Hello, how are you?" }
  ]
)
```

### Creating an assistant

```ruby
response = client.create_assistant(
  model: "gpt-4",
  name: "My Assistant",
  instructions: "You are a helpful AI assistant."
)
```

### Creating a thread and message

```ruby
thread = client.create_thread
client.create_message(
  thread_id: thread["id"],
  role: "user",
  content: "Hello, can you help me?"
)
```

### Creating a run in a thread

```ruby
client.create_thread_run(
  thread_id: thread["id"],
  assistant_id: "asst_123",
  instructions: "Please assist the user."
)
```

## Other Features

This gem also supports various other features such as:
- Deleting minds
- Retrieving assistants
- Deleting assistants
- Deleting threads
- Retrieving messages in a thread
- Getting information about a run

Refer to the documentation of each method in `Minds::Api::Client` for more details.

For comprehensive documentation on Minds, please visit: https://docs.mdb.ai/docs/data-mind

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at [here](https://github.com/tungnt1203/minds).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Minds project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tungnt1203/minds/blob/main/CODE_OF_CONDUCT.md).
