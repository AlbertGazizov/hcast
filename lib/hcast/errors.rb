module HCast::Errors

  # Base error class for all HCast errors
  class HCastError            < StandardError; end

  # Raised when caster with given name is not registered in HCast
  class CasterNotFoundError   < HCastError;    end

  # Raised when some of the given to HCast argument is not valid
  class ArgumentError         < HCastError;    end

  class AttributeError < HCastError
    attr_reader :namespaces

    def initialize(message, namespace = nil)
      super(message)
      @namespaces = []
      @namespaces << namespace if namespace
    end

    def add_namespace(namespace)
      namespaces << namespace
    end

    def message
      to_s
    end

    def to_s
      if namespaces.empty?
        super
      else
        reverted_namespaces = namespaces.reverse
        msg = reverted_namespaces.first.to_s
        msg += reverted_namespaces[1..-1].inject("") { |res, item| res += "[#{item}]"}
        msg + " " + super
      end
    end

  end
  # Raised when hash attribute can't be casted
  class CastingError < AttributeError;    end

  # Raised when required hash attribute wasn't given for casting
  class MissingAttributeError < AttributeError;    end

  # Raised when unexpected hash attribute was given for casting
  class UnexpectedAttributeError < AttributeError; end

  # Raised when hash has validation errors
  class ValidationError < StandardError
    attr_reader :errors

    def initialize(message, errors)
      @errors = errors
      super(message)
    end

    def message
      "#{@message}\n#{errors.to_hash}"
    end

    def short_message
      'Validation error'
    end
  end
end
