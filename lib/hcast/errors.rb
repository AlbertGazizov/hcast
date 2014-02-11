module HCast::Errors

  # Base error class for all HCast errors
  class HCastError            < StandardError; end

  # Raised when caster with given name is not registered in HCast
  class CasterNotFoundError   < HCastError;    end

  # Raised when some of the given to HCast argument is not valid
  class ArgumentError         < HCastError;    end

  # Raised when hash attribute can't be casted
  class CastingError          < HCastError;    end

  # Raised when required hash attribute wasn't given for casting
  class MissingAttributeError < HCastError;    end

  # Raised when unexpected hash attribute was given for casting
  class UnexpectedAttributeError < HCastError; end

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
