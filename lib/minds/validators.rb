# frozen_string_literal: true

module Minds
  module Validators
    class << self
      # Validates a mind name according to naming rules
      #
      # @param name [String] The mind name to validate
      # @return [Boolean] Returns true if valid
      # @raise [MindNameInvalid] If the mind name is invalid
      #
      # @example Valid mind names
      #   validate_mind_name!("my_mind_1") # => true
      #
      # @example Invalid mind names
      #   validate_mind_name!("123_mind") # raises MindNameInvalid
      #   validate_mind_name!("my mind") # raises MindNameInvalid
      #   validate_mind_name!("very_very_long_mind_name_over_32_chars") # raises MindNameInvalid
      #
      # @note Mind name rules:
      #   - Must start with a letter
      #   - Can contain only letters, numbers, or underscores
      #   - Maximum length of 32 characters
      #   - Cannot contain spaces
      def validate_mind_name!(name)
        unless name.match?(/\A[a-zA-Z][a-zA-Z0-9_]{0,31}\z/)
          raise MindNameInvalid, "Mind name '#{name}' is invalid. It must start with a letter, contain only letters, numbers, or underscores, and be 32 characters or less."
        end
      end

      # Validates a datasource name according to naming rules
      #
      # @param name [String] The datasource name to validate
      # @return [Boolean] Returns true if valid
      # @raise [DatasourceNameInvalid] If the datasource name is invalid
      #
      # @example Valid datasource names
      #   validate_datasource_name!("my_database") # => true
      #
      # @example Invalid datasource names
      #   validate_datasource_name!("123_db") # raises DatasourceNameInvalid
      #   validate_datasource_name!("my database") # raises DatasourceNameInvalid
      #   validate_datasource_name!("very_very_long_database_name_over_62_characters_not_allowed") # raises DatasourceNameInvalid
      #
      # @note Datasource name rules:
      #   - Must start with a letter
      #   - Can contain only letters, numbers, or underscores
      #   - Maximum length of 62 characters
      #   - Cannot contain spaces
      def validate_datasource_name!(name)
        unless name.match?(/\A[a-zA-Z][a-zA-Z0-9_]{0,61}\z/)
          raise DatasourceNameInvalid, "Datasource name '#{name}' is invalid. It must start with a letter, contain only letters, numbers, or underscores, and be 62 characters or less."
        end
      end
    end
  end
end
