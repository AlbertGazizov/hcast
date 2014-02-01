class HCast::Casters::FloatCaster

  def self.cast(value, attr_name)
    if value.is_a?(Float)
      value
    elsif value.is_a?(String)
      begin
        Float(value)
      rescue ArgumentError => e
        raise HCast::Errors::CastingError, "#{attr_name} is invalid float"
      end
    else
      raise HCast::Errors::CastingError, "#{attr_name} should be a float"
    end
  end

end
