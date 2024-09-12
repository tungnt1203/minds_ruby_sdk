## [Unreleased]

## [1.0.0] - 2024-09-10

### Added
- Initial release of the Minds gem
- Implemented `Minds::Api::Client` with methods for interacting with the Minds API:
  - `create_mind`
  - `delete_mind`
  - `chat_completion`
  - `create_assistant`
  - `get_assistants`
  - `delete_assistants`
  - `create_thread`
  - `delete_thread`
  - `create_message`
  - `get_thread_messages`
  - `create_thread_run`
  - `get_thread_run`
- Added `Minds::ApiClient` as a simplified version of the API client
- Added database configuration classes for various database types:
  - ClickHouse
  - MariaDB
  - MySQL
  - PostgreSQL
  - Amazon Redshift
  - Snowflake
  - Elasticsearch
