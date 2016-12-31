class HCast::Casters::FloatCaster

  def self.cast(value, attr_name, options = {})
    return value               if value.is_a?(Float)
    return cast_string(value)  if value.is_a?(String)
    raise HCast::Errors::CastingError, "#{value} should be a float"
  end

  def self.cast_string(value)
    Float(value)
  rescue ArgumentError => e
    raise HCast::Errors::CastingError, "#{value} is invalid float"
  end
end
