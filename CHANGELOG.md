## [Unreleased]

## [1.0.0] - 2024-10-14

### Added
- Initial release of the Minds Ruby SDK
- Implemented `Minds::Client` for configuring and initializing the SDK
- Added `Minds::Datasources` for managing data sources:
  - `create`: Create a new datasource
  - `all`: List all datasources
  - `find`: Get a datasource by name
  - `destroy`: Delete a datasource
- Added `Minds::Minds` for managing minds:
  - `all`: List all minds
  - `find`: Get a mind by name
  - `create`: Create a new mind
  - `destroy`: Delete a mind
- Implemented `Minds::Mind` class with methods:
  - `update`: Update mind properties
  - `add_datasources`: Add a datasource to a mind
  - `destroy_datasources`: Remove a datasource from a mind
  - `completion`: Call mind completion (with streaming support)
- Added support for various datasource types through `Minds::DatabaseConfig` class
- Implemented error handling with custom error classes
- Added YARD-style documentation for all public methods

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A
