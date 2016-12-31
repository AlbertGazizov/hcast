class HCast::Casters::SymbolCaster
  MAX_SYMBOL_LENGTH = 1000

  def self.cast(value, attr_name, options = {})
    return value              if value.is_a?(Symbol)
    return cast_string(value) if value.is_a?(String)
    raise HCast::Errors::CastingError, "should be a symbol"
  end

  def self.cast_string(value)
    if value.length > MAX_SYMBOL_LENGTH
      raise HCast::Errors::CastingError, "is too long to be a symbol"
    else
      value.to_sym
    end
  end

end
