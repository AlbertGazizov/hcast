module HCast::Errors
  class HCastError          < StandardError; end
  class CasterNotFoundError < HCastError;    end
  class ArgumentError       < HCastError;    end
  class CastingError        < HCastError;    end
end
