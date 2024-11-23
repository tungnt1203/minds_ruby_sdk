# frozen_string_literal: true

module Minds
  class Error < StandardError; end
  class ObjectNotFound < Error; end
  class ObjectNotSupported < Error; end
  class MindNameInvalid < Error; end
  class DatasourceNameInvalid < Error; end
end
