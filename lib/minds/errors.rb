module Minds
  class Error < StandardError; end
  class ValidationError < Error; end
  class ObjectNotFound < Error; end
  class ObjectNotSupported < Error; end
end
