class HCast::Casters::DateCaster

  def self.cast(value, attr_name, options = {})
    return value              if value.is_a?(Date)
    return cast_string(value) if value.is_a?(String)
    raise HCast::Errors::CastingError, "should be a date"
  end

  def self.cast_string(value)
    Date.parse(value)
  rescue ArgumentError => e
    raise HCast::Errors::CastingError, "is invalid date"
  end

end
