class HCast::Casters::SymbolCaster
  MAX_SYMBOL_LENGTH = 1000

  def self.cast(value, attr_name)
    if value.is_a?(Symbol)
      value
    elsif value.is_a?(String)
      if value.length > MAX_SYMBOL_LENGTH
        raise HCast::Errors::CastingError, "#{attr_name} is too long to be a symbol"
      else
        value.to_sym
      end
    else
      raise HCast::Errors::CastingError, "#{attr_name} should be a symbol"
    end
  end

end
